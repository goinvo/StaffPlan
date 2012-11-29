class window.StaffPlan.Views.Users.Edit extends Backbone.View
  tagName: "form"
  className: "form-horizontal padding-top-40"

  initialize: ->

  events: ->
    "change select[data-attribute=employment_status]": "refreshSalaryRelatedFields"
    "click div.form-actions a[data-action=update]": "saveUser"
  refreshSalaryRelatedFields: (event) ->
    selected = $(event.currentTarget).val()

    @$el.find('div#salary_information div.salary').hide()
    @$el.find('div#salary_information').find('input, select').prop('disabled', true)
    @$el.find('div#salary_information div.' + selected).find('input, select').show().prop('disabled', false)
    @$el.find('div#salary_information div.' + selected).show()

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
          error: (model, response) ->
            console.log "ERROR :/ " + response
          , {wait: true}
      error: (model, response) ->
        alert "Could not save the user to the database. ERROR: " + response
      , {wait: true}
    
  render: ->
    @$el.html StaffPlan.Templates.Users.edit.userEdit
      user: @model.attributes
      membership: @model.membership.attributes
    selected = @model.membership.get 'employment_status'
    @$el.find("select#user_employment_status").val(selected)
    @$el.find("div#salary_information div.salary").hide().find('input, select').prop('disabled', true)

    _.each (@model.membership.get 'permissions'), (perm) =>
      @$el.find("div#permissions input#user_permissions_" + perm + "[type=checkbox]").prop("checked", true)

    switch selected
      when "fte"
        _.each ["salary", "full_time_equivalent"], (attr) =>
          @$el.find("#user_" + attr + "").val @model.membership.get(attr)
      when "contractor"
        _.each ["weekly_allocation", "rate", "payment_frequency"], (attr) =>
          @$el.find("#user_" + attr + "").val @model.membership.get(attr)
    @$el.find("div#salary_information div." + selected + "").show().find('input, select').prop('disabled', false)
    @$el.appendTo("section.main")
