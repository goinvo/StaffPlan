class window.StaffPlan.Views.Users.New extends StaffPlan.View
  tagName: "form"
  className: "form-horizontal short"

  initialize: ->
    _.extend @, StaffPlan.Mixins.ValidationHandlers
  events: ->
    "change select[data-attribute=employment_status]": "refreshSalaryRelatedFields"
    "click div.form-actions a[data-action=create]": "createUser"
  
  # When the Employment status changes, we need to hide/show the irrelevant/relevant fields
  refreshSalaryRelatedFields: (event) ->
    selected = $(event.currentTarget).val()

    @$el.find('div#salary_information div.salary').hide()
    @$el.find('div#salary_information').find('input, select').prop('disabled', true)
    @$el.find('div#salary_information div.' + selected).find('input, select').show().prop('disabled', false)
    @$el.find('div#salary_information div.' + selected).show()

  createUser: =>
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
    @collection.create userAttributes,
      success: (model, response) =>
        membership = new window.StaffPlan.Models.Membership {user_id: model.id, company_id: window.StaffPlan.currentCompany.id},
          company_id: window.StaffPlan.currentCompany.id
          parent: model
        membership.save membershipAttributes,
          success: (resource, response) ->
            # Set the newly saved membership on the user
            model.membership.set resource
            Backbone.history.navigate("/users", true)
          error: (model, xhr, options) =>
            @errorHandler(xhr.responseText, "membership")
          , {wait: true}
      error: (model, xhr, options) =>
        options.collection.remove model
        @errorHandler(xhr.responseText, "user")
      , {wait: true}

  render: ->
    super
    
    @$el.find('section.main').html StaffPlan.Templates.Users.new.newUser

    @
