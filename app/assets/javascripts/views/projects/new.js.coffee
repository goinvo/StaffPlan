class window.StaffPlan.Views.Projects.New extends Support.CompositeView
  
  tagName: "form"
  className: "form-horizontal"

  initialize: ->
    @newClient = false
    @clients = @options.clients
    @currentUser = @options.currentUser
     
  templates:
    projectNew: '''
    <div data-model=client>
    
      <div class="control-group">
        <label class="control-label" for="client-name">
          Client
        </label>
        <div class="controls">
          <select id="client-picker">
            {{#clients}}
              <option value="{{id}}">{{name}}</option>
            {{/clients}}
            <option class="new-client" value="newclient">New Client</option>
          </select>
        </div>
      </div>
      
      <div class="control-group initially-hidden">
        <label class="control-label" for="client-name">    
          Client Name
        </label>
        <div class="controls">
          <input id="client-name" type="text" placeholder="Client Name">
        </div>
      </div>

    </div>
    
    <div data-model=project>

      <div class="control-group">
        <label class="control-label" for="project-name">    
          Project Name
        </label>
        <div class="controls">
          <input id="project-name" type="text" placeholder="Project Name">
        </div>
      </div>
      
      <div class="control-group">
        <label class="control-label" for="project-active">Active</label>
        <div class="controls">
          <input id="project-active" type="checkbox">
        </div>
      </div>
      
      <div class="control-group">
        <label class="control-label" for="project-proposed">Proposed</label>
        <div class="controls">
          <input id="project-proposed" type="checkbox">
        </div>
      </div>
      
      <div class="control-group">
        <label class="control-label">
          Payment Frequency
        </label>
        <input type="radio" checked="checked" value="monthly" id="project-payment-monthly" name="project-payment-frequency"> Monthly  
        <input type="radio" value="total" id="project-payment-total" name="project-payment-frequency"> Total
      </div>
        
       <div class="control-group">
         <label class="control-label" for="project-cost">Cost</label>
         <div class="controls">
           <input id="project-cost" size="10" type="number">
         </div>
       </div>
    
    </div>
    <div class="form-actions">
      <a href="/projects" data-action="create" class="btn btn-primary">Create project</a>
      <a href="/projects" data-action="cancel" class="btn">Back to list of projects</a>
    </div>

    '''
  
  events: ->
    "change select#client-picker": "clientSelectionChanged"
    "click div.form-actions a[data-action=create]": "createUser"


  createUser: ->
    if @newClient
      # First create the client
      @clients.create
        name: @$el.find("#client-name").val()
      , success: (model, response) =>
          console.log "SUCCESS SAVING THE CLIENT"
          # On success, create the project
          @collection.create
            name: @$el.find("#project-name").val()
            active: @$el.find("#project-active").prop("checked")
            payment_frequency: @$el.find("input[name=project-payment-frequency]:checked").val()
            cost: @$el.find("#project-cost").val()
            company_id: window.StaffPlan.currentCompany.id
            client_id: model.id
          , success: (model, response) ->
              console.log "SUCCESS SAVING THE PROJECT"
          , error: (model, response) ->
              console.log "FAILED TO SAVE THE PROJECT"
      , error: (model, response) ->
          console.log "FAILED TO SAVE THE CLIENT"
    else
      @collection.create
        name: @$el.find("#project-name").val()
        active: @$el.find("#project-active").prop("checked")
        payment_frequency: @$el.find("input[name=project-payment-frequency]:checked").val()
        cost: @$el.find("#project-cost").val()
        company_id: window.StaffPlan.currentCompany.id
        client_id: @$el.find("#client-picker").val()
      , success: (model, response) =>
          @currentUser.assignments.create
            project_id: model.id
            user_id: @currentUser.id
            proposed: @$el.find("#project-proposed").prop("checked")
            , success: (model, response) ->
                console.log "SUCCESS SAVING THE ASSIGNMENT"
            , error: (model, response) ->
                console.log "FAILED TO SAVE THE ASSIGNMENT"
      , error: (model, response) ->
          console.log "FAILED TO SAVE THE PROJECT WITH A PRE-EXISTING CLIENT"
  clientSelectionChanged: (event) ->
    newClientSelected = $(event.currentTarget).find("option:selected").hasClass "new-client"
    if @newClient isnt newClientSelected
      @$el.find(".initially-hidden").fadeToggle "slow"
    @newClient = newClientSelected

  render: ->
    @$el.append Handlebars.compile(@templates.projectNew)
      clients: @clients.map (client) -> client.toJSON()
    @$el.find(".initially-hidden").hide()
    @$el.appendTo "section.main"

    @
