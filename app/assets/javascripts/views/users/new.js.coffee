class window.StaffPlan.Views.Users.New extends StaffPlan.View
  tagName: "form"
  className: "form-horizontal short"

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
    event.preventDefault()
    event.stopPropagation()
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
      success: (model, response) =>
        # We have a new user
        membership = new window.StaffPlan.Models.Membership
          company_id: window.StaffPlan.currentCompany.id
        membership.save (_.extend membershipAttributes, {user_id: model.id}),
          success: (resource, response) ->
            model.membership.set resource
          error: (model, xhr, options) =>
            errors = JSON.parse xhr.responseText
            membershipDiv = @$el.find('div[data-model=membership]')
            _.each errors, (value, key) =>
              group = membershipDiv.find("[data-attribute=#{key}]").closest('div.control-group')
              group.addClass("error")
              errorList = "<ul>" + (_.map value, (error) -> "<li>#{error}</li>") + "</ul>"
              group.find("div.controls").append("<span class=\"validation-errors\">#{errorList}</span>")
          , {wait: true}
      error: (model, xhr, options) =>
        # FIXME: That belongs in a mixin so that we can reuse this somewhere else
        errors = JSON.parse xhr.responseText
        userDiv = @$el.find('div[data-model=user]')
        _.each errors, (value, key) =>
          group = userDiv.find("[data-attribute=#{key}]").closest('div.control-group')
          group.addClass("error")
          errorList = "<ul>" + (_.map value, (error) -> "<li>#{error}</li>") + "</ul>"
          group.find("div.controls").append("<span class=\"validation-errors\">#{errorList}</span>")
      , {wait: true}

  render: ->
    super
    
    @$el.find('section.main').html StaffPlan.Templates.Users.new.newUser
    # Hides the appropriate fields so that we can handle the permissions information
    selected = @$el.find('select[data-attribute="employment_status"]').val()
    @$el.find("div#salary_information div.salary").hide().find('input, select').prop('disabled', true)
    @$el.find("div#salary_information div." + selected + "").show().find('input, select').prop('disabled', false)

    @
