class window.StaffPlan.Views.StaffPlans.Assignment extends Backbone.View
  className: "assignment-row grid-row padded"
  tagName: "div"
  
  templates:
    show: '''
      <div class="grid-row-element fixed-180 sexy">
        <div class='client-or-project-name'>{{clientName}}</div>
        {{#if showAddProject}}
        <span class='plus-with-text'>
          <a class='add-project return-false' href="/staffplans/{{user_id}}">
            <i class='icon-plus'>&nbsp;</i>
            <span class='text'>Project</span>
          </a>
        </span>
        {{/if}}
      </div>
      <div class="grid-row-element fixed-180 sexy">{{projectName}}</div>
      <div class="grid-row-element flex work-weeks"></div>
    '''
    
    new: '''
    <div class="grid-row-element fixed-180 sexy">
      {{#if showClientInput}}
        <input type="text" class="client-name-input input-medium" data-model="Client" data-attribute="name" data-trigger-save placeholder="Client Name" />
      {{/if}}
    </div>
    <div class="grid-row-element fixed-180 sexy">
      <input type="text" class="project-name-input input-medium" data-model="Project" data-attribute="name" data-trigger-save placeholder="Project Name" />
    </div>
    <div class="grid-row-element flex">
      <input type="button" class='btn btn-mini' data-trigger-save value="Save" />
    </div>
    '''
  
  project: ->
    StaffPlan.projects.get( @model.get 'project_id' )
    
  client: ->
    StaffPlan.clients.get( @project()?.get('client_id') )
    
  initialize: ->
    @model = @options.model
    @user = @options.user
    @index = @options.index
    
    @showTemplate = Handlebars.compile @templates.show
    @newTemplate = Handlebars.compile @templates.new
    
    @$el.data('cid', @cid)
    
    @workWeeksView = new window.StaffPlan.Views.StaffPlans.WorkWeeks
      collection: @model.work_weeks
      user: @user
  
  ensureWorkWeekRange: =>
    # pads this assignment's work weeks for the selected date range adding new WorKWeek objects where needed to all inputs are rendered.
    for meta in @user.view.getYearsAndWeeks()
      unless _.any(@model.work_weeks.where({cweek: meta.cweek, year: meta.year}))
        @model.work_weeks.add
          cweek: meta.cweek
          year: meta.year
  
  renderNew: ->
    @$el.html @newTemplate
      showClientInput: @client() == undefined or @client().isNew()
  
  renderShow: ->
    @$el.html @showTemplate
      showAddProject: @index == 0
      clientName: if @index == 0 then @client().get('name') else ""
      projectName: @project()?.get('name')
      user_id: @user.id
    
    @ensureWorkWeekRange()
    
    @$el.find( 'div.work-weeks' ).append @workWeeksView.render().el
    
  render: ->
    if @model.isNew() then @renderNew() else @renderShow()
    @
  
  events:
    "click input[type='button'][data-trigger-save]": "onSaveTriggered"
    "keydown input[type='text'][data-trigger-save]": "onSaveTriggeredByKeydown"
  
  onSaveTriggeredByKeydown: (event) ->
    if event.keyCode == 13
      @onSaveTriggered(event)
  
  onSaveTriggered: (event) ->
    clientNameValue = @$el.find('[data-model="Client"][data-attribute="name"]').val()
    client = StaffPlan.clients.get(@model.get('client_id'))
    
    unless client?
      client = StaffPlan.clients.where(name: clientNameValue)[0]
      
    unless client?
      StaffPlan.addClientByName clientNameValue, (client, reponse) =>
        @addProjectByNameAndClient client
    else
      @addProjectByNameAndClient client
    
  addProjectByNameAndClient: (client) ->
    projectNameValue = @$el.find('[data-model="Project"][data-attribute="name"]').val()
    unless (project = _.first StaffPlan.projects.where(name: projectNameValue, client_id: client.get('id')))?
      StaffPlan.addProjectByNameAndClient projectNameValue, client, (project, response) =>
        @_save project
    else
      @_save project
  
  _save: (project) =>
    @model.save
      project_id: project.get('id')
      target_user_id: @user.get('id')
    ,
      success: (assignment, response) =>
        assignment.view.user.view.clients.add() if $('[data-client-id="-1"]').length == 0