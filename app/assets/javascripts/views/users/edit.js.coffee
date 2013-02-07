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
    "change div.upload input[type=file]": "displayPreview"
    "click div.upload button[data-action=upload]": "uploadImageFile"

  displayPreview: (event) ->
    imgFile = _.first event.target.files

    reader = new FileReader

    reader.onload = (event) =>
      # We might want to check whether or not there's already a preview
      # being displayed in the target div (for the case where the user
      # selected the wrong file and is trying again)
      preview = document.createElement "img"
      preview.src = event.target.result
      # The image will be that size eventually, show it as is right away
      preview.width = 70
      preview.height = 70
      @$el.find("div.upload").append preview
      # Stay classy
      @$el.find("div.upload").append '<button data-action=upload class="btn btn-primary">Upload</button>'

    reader.readAsDataURL imgFile

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
          success: (resource, response) ->
            # Successful save for the membership, let's embed it in the User model client-side
            model.membership.set resource
            Backbone.history.navigate("/users", true)
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
      membershipInfo: @model.getMembershipInformation()
    
    @
