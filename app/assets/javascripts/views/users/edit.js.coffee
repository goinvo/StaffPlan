class window.StaffPlan.Views.Users.Edit extends Backbone.View
  tagName: "form"
  className: "form-horizontal"
  templates:
    userEdit: '''
    <div data-model=user>
      
      <div class="control-group">
        <label class="control-label" for="user_first_name">First name</label>
        <div class="controls">
          <input id="user_first_name" data-attribute=first_name size="30" type="text" value={{user.first_name}}>
        </div>
      </div>

      <div class="control-group">
        <label class="control-label" for="user_last_name">Last name</label>
        <div class="controls">
          <input id="user_last_name" data-attribute=last_name size="30" type="text" value={{user.last_name}}>
        </div>
     </div>

      <div class="control-group">
        <label class="control-label" for="user_email">Email</label>
        <div class="controls">
          <input id="user_email" data-attribute=email size="30" type="text" value="{{user.email}}">
        </div>
      </div>

    <div data-model=membership> 
      <div id="employment_status">
        <div class="control-group">
          <label class="control-label" for="user_employment_status">Employment status</label>
          <div class="controls">
            <select id="user_employment_status" data-attribute=employment_status>
              <option value="fte">Full-Time Employee</option>
              <option value="contractor">Contractor</option>
              <option value="intern">Intern</option>
            </select>
          </div>
        </div>
      </div>
      
      <div id="permissions">
        <div class="control-group">
          <label class="control-label checkbox" for="user_permissions_admin"></label>
          <div class="controls">
            <input id="user_permissions_admin" data-attribute=permissions type="checkbox" value="admin">Admin
          </div>
        </div>
        <div class="control-group">
          <label class="control-label checkbox" for="user_permissions_financials"></label>
          <div class="controls">
            <input id="user_permissions_financials" data-attribute=permissions type="checkbox" value="financials">Financials
          </div>
        </div>
      </div>


      <div id="salary_information">
        <div class="salary fte">
          <div class="control-group">
            <label class="control-label" for="user_salary">Salary</label>
            <div class="controls">
              <input id="user_salary" data-attribute=salary size="30" type="number">
            </div>
          </div>
          <div class="control-group">
            <label class="control-label" for="user_fte">Full-Time Equivalent</label>
            <div class="controls">
              <input id="user_full_time_equivalent" data-attribute=full_time_equivalent size="30" type="number">
            </div>
          </div>
        </div>
        
        <div class="salary contractor">
          
          <div class="control-group">
            <label class="control-label" for="user_weekly_allocation">Weekly allocation</label>
            <div class="controls">
              <input id="user_weekly_allocation" data-attribute=weekly_allocation size="30" type="number">
            </div>
          </div>

          <div class="control-group">
            <label class="control-label" for="user_payment_frequency">Payment frequency</label>
            <div class="controls">
              <select id="user_payment_frequency" data-attribute=payment_frequency>
                <option value="hourly">hourly</option>
                <option value="daily">daily</option>
                <option value="weekly">weekly</option>
                <option value="monthly">monthly</option>
                <option value="yearly">yearly</option>
              </select>
            </div>
          </div>
          <div class="control-group">
            <label class="control-label" for="user_rate">Rate</label>
            <div class="controls">  
              <input id="user_rate" data-attribute=rate size="30" type="number"></div>
            </div>
          </div>

        </div>
      </div>
    </div>

    <div class="form-actions">
      <a href="#" data-action="update" type="submit" class="btn btn-primary">Update user</a>
      <a href="/users" data-action="cancel" type="button" class="btn">Back to list of users</a>
    </div>
    '''
  initialize: ->
    @userEditTemplate = Handlebars.compile(@templates.userEdit)
    @$el.html @userEditTemplate
      user: @model.attributes
      membership: @model.membership.attributes

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
    
      

    # @model.membership = @model.membership.set membershipAttributes
    
    # @model.set userAttributes

    # @model.save {},
    #   success: (model, response) ->
    #     Backbone.history.navigate("/staffplans", true)
    #   error: (model, response) ->
    #     alert "something went wrong"
  
  render: ->
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
