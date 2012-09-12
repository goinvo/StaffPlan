class window.StaffPlan.Views.Users.New extends Support.CompositeView
  templates:
    userNew: '''
    <!-- BASE ATTRIBUTES -->
    <h2>First name</h2>
    <input data-attribute=first_name placeholder="First Name" size="30" type="text">

    <h2>Last name</h2>
    <input data-attribute=last_name placeholder="Last Name" size="30" type="text">

    <h2>Email</h2>
    <input data-attribute=email placeholder="user@host.tld" size="30" type="text">
    
    
    <!-- EMPLOYMENT STATUS -->
    <div id="employment_status">
      <h2>Employment status</h2>
      <select data-attribute=membership.employment_status>
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
        <input data-attribute=membership.permissions type="checkbox" value="admin">
      </div>
      <div class="perm">
        <label>Financials</label>
        <input data-attribute=membership.permissions type="checkbox" value="financials">
      </div>
    </div>


    <!-- SALARY INFORMATION -->
    <div id="salary_information">
      <div class="salary fte">
        <h2>Salary</h2>
        <input data-attribute=membership.salary size="30" type="number"></div>
        <h2>Full-Time Equivalent</h2>
        <input data-attribute=membership.full_time_equivalent size="30" type="number">
      </div>
      
      <div class="salary contractor">
        <h2>Weekly allocation</h2>
        <input data-attribute=membership.weekly_allocation size="30" type="number">
        
        <h2>Payment frequency</h2>
        <select data-attribute=membership.payment_frequency>
          <option value="hourly">hourly</option>
          <option value="daily">daily</option>
          <option value="weekly">weekly</option>
          <option value="monthly">monthly</option>
          <option value="yearly">yearly</option>
        </select>
        
        <h2>Rate</h2>
        <input data-attribute=membership.rate size="30" type="number"></div>
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
    "change select[data-attribute=membership.employment_status]": "refreshSalaryRelatedFields"
    "click div.actions input[type=submit]": "saveUser"
  
  refreshSalaryRelatedFields: (event) ->
    selection = $(event.currentTarget).val()
    console.log selection

  saveUser: =>
    serializedForm = {}
    _.each @$el.find('[data-attribute]'), (element) ->
      setValueAt serializedForm, $(element).data('attribute').split("."), $(element).val()
    
    # Should work for both new and edit :/ 
    @collection.create serializedForm,
      wait: true # Best to wait for a successful CREATE server-side to add the model to the collection
      error: (model, response) =>
        alert "An error prevented the User from being saved."
      success: (model, response) =>
        Backbone.history.navigate("/staffplans", true)
  
  render: ->
    @$el.appendTo("section.main .content")

