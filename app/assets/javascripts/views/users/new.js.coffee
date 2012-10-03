class window.StaffPlan.Views.Users.New extends Support.CompositeView
  tagName: "form"
  className: "form-horizontal"
  templates:
    userNew: '''
    <div data-model=user>
      <div class="control-group">
        <label class="control-label" for="user_first_name">First name</label>
        <div class="controls">
          <input id="user_first_name" data-attribute=first_name placeholder="First Name" size="30" type="text">
        </div>
      </div>

      <div class="control-group">
        <label class="control-label" for="user_last_name">Last name</label>
        <div class="controls">
          <input id="user_last_name" data-attribute=last_name placeholder="Last Name" size="30" type="text">
        </div>
      </div>

      <div class="control-group">
        <label class="control-label" for="user_email">Email</label>
        <div class="controls">
          <input id="user_email" data-attribute=email placeholder="user@host.tld" size="30" type="text">
        </div>
      </div>
    </div>

    <div data-model=membership> 
      <div id="employment_status">
        <div class="control-group">
          <label class="control-label" for="user_employment_status">Employment status</label>
          <div class="controls">
            <select id="user_employment_status" data-attribute=employment_status>
              <option value="fte" selected="selected">Full-Time Employee</option>
              <option value="contractor">Contractor</option>
              <option value="intern">Intern</option>
            </select>
          </div>
        </div>
      </div>
      
      
      <div id="permissions">
        <div class="control-group">
          <label class="control-label" for="user_permissions_admin">Admin</label>
          <div class="controls">
            <input id="user_permissions_admin" data-attribute=permissions type="checkbox" value="admin">
          </div>
        </div>
        <div class="control-group">
          <label class="control-label" for="user_permissions_financials">Financials</label>
          <div class="controls">
            <input id="user_permissions_financials" data-attribute=permissions type="checkbox" value="financials">
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
              <input id="user_fte" data-attribute=full_time_equivalent size="30" type="number">
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
      <button data-action="new" type="submit" class="btn btn-primary">Create user</button>
      <button data-action="cancel" type="button" class="btn">Back to list of users</button>
    </div>

    '''
  initialize: ->
    @userNewTemplate = Handlebars.compile(@templates.userNew)
    @$el.html @userNewTemplate

    @render()
  events: ->
    "change select[data-attribute=employment_status]": "refreshSalaryRelatedFields"
    "click div.form-actions input[type=submit]": "saveUser"
  
  refreshSalaryRelatedFields: (event) ->
    selected = $(event.currentTarget).val()

    @$el.find('div#salary_information div.salary').hide()
    @$el.find('div#salary_information').find('input, select').prop('disabled', true)
    @$el.find('div#salary_information div.' + selected).find('input, select').show().prop('disabled', false)
    @$el.find('div#salary_information div.' + selected).show()

  saveUser: =>
    userAttributes = _.reduce $("div[data-model=user] input:not(:disabled)"), (memo, elem) ->
        memo[$(elem).data('attribute')] = $(elem).val()
        memo
      , {}
    
    membershipAttributes = _.reduce $("div[data-model=membership] input:not(:disabled)"), (memo, elem) ->
        if $(elem).data('attribute') is "permissions"
          memo['permissions'].push $(elem).val()
        else
          memo[$(elem).data('attribute')] = $(elem).val()
        memo
      , {permissions: []}

    membership = new window.StaffPlan.Models.Membership membershipAttributes
    @model.set('membership', membership)
    @model.set userAttributes

    @collection.add @model
    @model.save {},
      success: (model, response) ->
        Backbone.history.navigate("/staffplans", true)
      error: (model, response) ->
        @collection.remove model
        alert "something went wrong"
  render: ->
    @$el.appendTo("section.main .content")
    # Hides the appropriate fields so that we can handle the permissions information
    selected = $('select[data-attribute="employment_status"]').val()
    $("div#salary_information div.salary").hide().find('input, select').prop('disabled', true)
    $("div#salary_information div." + selected + "").show().find('input, select').prop('disabled', false)

