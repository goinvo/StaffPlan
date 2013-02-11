class window.StaffPlan.Views.Users.Edit extends StaffPlan.View
  tagName: "form"
  className: "form-horizontal short"

  initialize: ->
    _.extend @, StaffPlan.Mixins.ValidationHandlers
    @model.membership.on "change:employment_status", (event) =>
      @render()

  events: ->
    "change select[data-attribute=employment_status]": "refreshSalaryRelatedFields"
    "click div.form-actions a[data-action=update]": "saveUser"
    "click div.upload a[data-action=add-file-chooser]": "addFileChooser"
    "change div.upload input[type=file]": "uploadImageFile"

  addFileChooser: (event) ->
    event.preventDefault()
    event.stopPropagation()
    $(event.target).replaceWith("<input type=file>")
  uploadImageFile: (event) ->
    event.preventDefault()
    event.stopPropagation()
    imgFile = _.first @$el.find("div.upload input[type=file]")[0].files

    xhr = new XMLHttpRequest

    xhr.onload = (event) =>
      @model.set "gravatar", JSON.parse(event.currentTarget.response).src
      @render()


    xhr.open("POST", "/users/#{@model.id}/avatar", true)
    xhr.setRequestHeader("Content-Disposition", "form-data")
    xhr.setRequestHeader("Content-Type", "image/png")
    # Indicate the file name, size and type
    xhr.setRequestHeader("X-Accept", "application/json, text/javascript, */*; q=0.01")
    xhr.setRequestHeader("X-File-Name", imgFile.name)
    xhr.setRequestHeader("X-File-Size", imgFile.size)
    xhr.setRequestHeader("X-File-Type", imgFile.type)
    xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'))
    # WHEEEEE !!!!
    xhr.send(imgFile)

  refreshSalaryRelatedFields: ->
    @model.membership.set "employment_status", $(event.target).val()

  saveUser: ->
    event.preventDefault()
    event.stopPropagation()
    userAttributes = _.reduce $("div[data-model=user] input:not(:disabled)"), (memo, elem) ->
        memo[$(elem).data('attribute')] = $(elem).val()
        memo
      , {}
    
    preferencesAttributes = _.reduce $("div[data-model=user_preferences] input:not(:disabled), select:not(:disabled)"), (memo, elem) ->
        memo[$(elem).data('attribute')] = if $(elem).prop("checked") then true else false
        memo
      , {}

    membershipAttributes = _.reduce $("div[data-model=membership] input:not(:disabled), select:not(:disabled)"), (memo, elem) ->
        if $(elem).data('attribute') is "permissions"
          if $(elem).prop('checked')
            if not memo['permissions']?
              memo['permissions'] = [$(elem).val()]
            else
              memo['permissions'].push $(elem).val()
        else
          memo[$(elem).data('attribute')] = $(elem).val()
        memo
      , {}
    @model.save userAttributes,
      success: (model, response) =>
        # We have a new user
        @model.membership.save membershipAttributes,
          success: (resource, response) =>
            model.membership.set resource
            @model.preferences.save preferencesAttributes,
              success: (resource, response) ->
                console.log resource
                Backbone.history.navigate("/users", true)
              error: (model, xhr, options) =>
                @errorHandler xhr, "preferences"
          error: (model, xhr, options) =>
            @errorHandler xhr, "membership"
          , {wait: true}
      error: (model, xhr, options) =>
        @errorHandler xhr.responseText, "user"
      , {wait: true}
  
  render: ->
    super

    @$el.find('section.main').html StaffPlan.Templates.Users.edit.userEdit
      user: @model.attributes
      emailReminder: @model.preferences.get("email_reminder")
      membershipInfo: @model.getMembershipInformation()
    
    @
