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
