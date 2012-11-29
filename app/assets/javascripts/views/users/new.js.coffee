class window.StaffPlan.Views.Users.New extends Support.CompositeView
  tagName: "form"
  className: "form-horizontal padding-top-40"
  
  initialize: ->

  events: ->
    "change select[data-attribute=employment_status]": "refreshSalaryRelatedFields"
    "click div.form-actions a[data-action=create]": "createUser"
  
  refreshSalaryRelatedFields: (event) ->
    selected = $(event.currentTarget).val()

    @$el.find('div#salary_information div.salary').hide()
    @$el.find('div#salary_information').find('input, select').prop('disabled', true)
    @$el.find('div#salary_information div.' + selected).find('input, select').show().prop('disabled', false)
    @$el.find('div#salary_information div.' + selected).show()

  createUser: =>
    userAttributes = _.reduce $("div[data-model=user] input:not(:disabled)"), (memo, elem) ->
        memo[$(elem).data('attribute')] = $(elem).val()
        memo
      , {}
    
    membershipAttributes = _.reduce $("div[data-model=membership] input:not(:disabled)"), (memo, elem) ->
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
      success: (model, response) ->
        # We have a new user
        membership = new window.StaffPlan.Models.Membership
          company_id: window.StaffPlan.currentCompany.id
        membership.save (_.extend membershipAttributes, {user_id: model.id}),
          success: (resource, response) ->
            # Successful save for the membership, let's embed it in the User model client-side
            model.membership.set resource
          error: (model, response) ->
            console.log "ERROR :/ " + response
          , {wait: true}
      error: (model, response) ->
        alert "Could not save the user to the database. ERROR: " + response
      , {wait: true}

  render: ->
    @$el.html StaffPlan.Templates.Users.new.newUser
    @$el.appendTo("section.main")
    # Hides the appropriate fields so that we can handle the permissions information
    selected = $('select[data-attribute="employment_status"]').val()
    $("div#salary_information div.salary").hide().find('input, select').prop('disabled', true)
    $("div#salary_information div." + selected + "").show().find('input, select').prop('disabled', false)

