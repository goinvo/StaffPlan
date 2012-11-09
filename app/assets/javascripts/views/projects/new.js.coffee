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
          <select data-model=client data-attribute=id id="client-picker">
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
          <input data-model=client data-attribute=name id="client-name" type="text" placeholder="Client Name">
        </div>
      </div>

    </div>
    
    <div data-model=project>

      <div class="control-group">
        <label class="control-label" for="project-name">    
          Project Name
        </label>
        <div class="controls">
          <input data-model=project data-attribute=name id="project-name" type="text" placeholder="Project Name">
        </div>
      </div>
      
      <div class="control-group">
        <label class="control-label" for="project-active">Active</label>
        <div class="controls">
          <input data-model=project data-attribute=active id="project-active" type="checkbox">
        </div>
      </div>
      
      <div class="control-group">
        <label class="control-label" for="project-proposed">Proposed</label>
        <div class="controls">
          <input data-model=project data-attribute=proposed id="project-proposed" type="checkbox">
        </div>
      </div>
      
      <div class="control-group">
        <label class="control-label">
          Payment Frequency
        </label>
        <radiogroup data-model=project data-attribute=payment_frequency>
          <input data-model=project data-attribute=payment_frequency type="radio" checked="checked" value="monthly"> Monthly  
          <input data-model=project data-attribute=payment_frequency type="radio" value="total"> Total
        </radiogroup>
      </div>
        
       <div class="control-group">
         <label class="control-label" for="project-cost">Cost</label>
         <div class="controls">
           <input data-model=project data-attribute=cost id="project-cost" size="10" type="number">
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
    formValues = @getFormValues("input, select")
    if @newClient
      # First create the client
      @clients.create { name: formValues.client.name },
        success: (model, response) =>
          @createProjectAndAssignment model.id, formValues
        error: (model, response) ->
    else
      @createProjectAndAssignment formValues.client.id, formValues

  createProjectAndAssignment: (clientId, formValues) ->
    # Each model should expose a whitelistedAttributes so that we only transmit what's needed
    projectAttributes = _.extend (_.pick formValues.project, ['name', 'active', 'payment_frequency', 'cost']),
      company_id: window.StaffPlan.currentCompany.id
      client_id: clientId
    @collection.create projectAttributes,
      success: (model, response) =>
        # Each model should expose a whitelistedAttributes so that we only transmit what's needed
        assignmentAttributes =
          project_id: model.id
          user_id: @currentUser.id
          proposed: formValues.project.proposed
        StaffPlan.assignments.create assignmentAttributes,
          success: (model, response) ->
          error: (model, response) ->
      error: (model, response) ->


  clientSelectionChanged: (event) ->
    newClientSelected = $(event.currentTarget).find("option:selected").hasClass "new-client"
    if @newClient isnt newClientSelected
      @$el.find(".initially-hidden").fadeToggle "slow"
    @newClient = newClientSelected

  
  # TODO: Only handles base elements like inputs and selects
  getFormValues: (selector) ->
    _.reduce @$el.find(selector), (values, formElement) =>
      values[$(formElement).data('model')][$(formElement).data('attribute')] = @getFormElementValue formElement
      values
    , _.chain(@$el.find selector)
        .map( (e) ->
          $(e).data "model"
        )
        .uniq()
        .reduce( (m, e) ->
          m[e] = {}
          m
        , {}
        )
        .value()
  
  getFormElementValue: (element) ->
    switch $(element).prop('tagName').toLowerCase()
      when "select"
        return $(element).val()
      when "input"
        switch $(element).attr "type"
          when "number", "text"
            return $(element).val()
          when "radio"
            $(element).closest('radiogroup').find('input[type=radio]:checked').val()
          when "checkbox"
            return $(element).prop "checked"
      
      
      
  render: ->
    @$el.append Handlebars.compile(@templates.projectNew)
      clients: @clients.map (client) -> client.toJSON()
    @$el.find(".initially-hidden").hide()
    @$el.appendTo "section.main"

    @
