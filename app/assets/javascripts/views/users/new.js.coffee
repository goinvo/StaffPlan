class window.StaffPlan.Views.Users.New extends Support.CompositeView
  templates:
    userNew: '''
    <!-- BASE ATTRIBUTES -->
    <h2>First name</h2>
    <input data-user-attribute data-key-path="first_name" placeholder="First Name" size="30" type="text">

    <h2>Last name</h2>
    <input data-user-attribute data-key-path="last_name" placeholder="Last Name" size="30" type="text">

    <h2>Email</h2>
    <input data-user-attribute data-key-path="email" placeholder="user@host.tld" size="30" type="text">
    
    
    <!-- EMPLOYMENT STATUS -->
    <div id="employment_status">
      <h2>Employment status</h2>
      <select data-user-attribute data-key-path=membership.employment_status>
        <option value="fte" selected="selected">Full-Time Employee</option>
        <option value="contractor">Contractor</option>
        <option value="intern">Intern</option>
      </select>
    </div>
    
    
    <!-- PERMISSIONS -->
    <div id="permissions">
      <h2>Permissions</h2>
      <div class="perm">
        <label>Admin</label>
        <input type="checkbox" value="admin">
      </div>
      <div class="perm">
        <label>Financials</label>
        <input type="checkbox" value="financials">
      </div>
    </div>


    <!-- SALARY INFORMATION -->
    <div id="salary_information">
      <div class="salary fte">
        <h2>Salary</h2>
        <input data-user-attribute data-key-path="membership.salary" size="30" type="number"></div>
        <h2>Full-Time Equivalent</h2>
        <input data-key-path="membership.full_time_equivalent" size="30" type="number">
      </div>
      
      <div class="salary contractor">
        <h2>Weekly allocation</h2>
        <input data-user-attribute data-key-path="membership.weekly_allocation" size="30" type="number">
        
        <h2>Payment frequency</h2>
        <select data-user-attribute data-key-path="membership.payment_frequency">
          <option value="hourly">hourly</option>
          <option value="daily">daily</option>
          <option value="weekly">weekly</option>
          <option value="monthly">monthly</option>
          <option value="yearly">yearly</option>
        </select>
        
        <h2>Rate</h2>
        <input data-user-attribute data-key-path="membership.rate" size="30" type="number"></div>
      </div>
    </div>


    <!-- ACTIONS -->
    <div class="actions">
      <input name="commit" type="submit" value="Send Invitation">
    </div>
    '''
  initialize: ->
    @userNewTemplate = Handlebars.compile(@templates.userNew)
    @$el.html @userNewTemplate
    @render()
  events: ->
    "change select[data-key-path=membership.employment_status]": "refreshSalaryRelatedFields"
    "click div.actions input[type=submit]": "debugSerializedForm"
  refreshSalaryRelatedFields: ->
  debugSerializedForm: ->
    # AWFUL
    serializedForm = {membership: {}}
    _.each @$el.find('[data-user-attribute]'), (element) ->
      if $(element).data('key-path').split(".")[0] == "membership"
        serializedForm['membership'][$(element).data('key-path').split(".")[1]] = $(element).val()
      else
        serializedForm[$(element).data('key-path')] = $(element).val()
    console.log serializedForm
  render: ->
    @$el.appendTo("section.main .content")

