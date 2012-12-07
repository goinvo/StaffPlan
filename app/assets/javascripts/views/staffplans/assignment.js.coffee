class window.StaffPlan.Views.StaffPlans.Assignment extends Support.CompositeView
  className: "assignment-row grid-row padded"
  tagName: "div"
  
  project: ->
    StaffPlan.projects.get( @model.get 'project_id' )
    
  client: ->
    StaffPlan.clients.get( @model.get('client_id') )
    
  leave: ->
    @model.off()
    @off()
    @remove()

  initialize: ->
    _.extend @, StaffPlan.Mixins.Events.weeks
    @model = @options.model
    @user = @options.user
    @index = @options.index
    @startDate = @options.startDate
    
    @on "date:changed", (message) =>
      @ensureWorkWeekRange()
      @dateChanged(message.action)
      
    @on "window:resized", =>
      @ensureWorkWeekRange()
      @onWindowResized()
      
    @model.bind 'change:id', => @render()


  ensureWorkWeekRange: =>
    # pads this assignment's work weeks for the selected date range adding new WorKWeek objects where needed so all inputs are rendered.
    for timestamp in @user.view.getYearsAndWeeks()
      unless (@model.work_weeks.detect (week) -> timestamp is week.get("beginning_of_week"))
        @model.work_weeks.add
          beginning_of_week: timestamp
    
  isDeletable: ->
    !@model.work_weeks.any (ww) -> ww.get('actual_hours')? && ww.get('actual_hours') > 0
    
  render: ->
    @$el.empty().data('cid', @cid)
    
    if @model.isNew()
      isNewClient = if @client()? @client().isNew() else true
      @$el.html StaffPlan.Templates.StaffPlans.assignment_new
        showClientInput: isNewClient
      
      setTimeout =>
        $('html, body').stop().animate
          scrollTop: (@$el.offset().top - 300)
        , 1000, 'swing', =>
          @$el.find("input.#{if isNewClient then "client" else "project"}-name-input").focus()
        
    else
      @$el.html StaffPlan.Templates.StaffPlans.assignment_show
        showAddProject: @index == 0
        client:
          name: if @index == 0 then @client().get('name') else ""
          id: @client().get('id')
        project:
          name: @project()?.get('name')
          id: @project()?.get('id')
        user_id: @user.id
        isDeletable: @isDeletable()
    
      @ensureWorkWeekRange()
      
      assignmentActionsView = new StaffPlan.Views.StaffPlans.AssignmentActions
        model: @model
        parent: @
      @appendChildTo assignmentActionsView, @$el.find('.assignment-actions-target')
      
      workWeeksView = new window.StaffPlan.Views.StaffPlans.WorkWeeks
        collection: @model.work_weeks
        user: @user
        startDate: @startDate
      @appendChildTo workWeeksView, @$el.find('div.work-weeks')
      
      assignmentTotalsView = new StaffPlan.Views.StaffPlans.AssignmentTotals
        model: @model
        parent: @
      @appendChild assignmentTotalsView
      
    @
  
  events:
    "click input[type='button'][data-trigger-save]": "onSaveTriggered"
    "keydown input[type='text'][data-trigger-save]": "onSaveTriggeredByKeydown"
    "click a.delete-assignment": "onDeleteAssignmentClicked"
  
  onDeleteAssignmentClicked: (event) ->
    @model.destroy()
    @remove()
  
  onSaveTriggeredByKeydown: (event) ->
    if event.keyCode == 13
      @onSaveTriggered(event)
  
  onSaveTriggered: (event) ->
    clientNameValue = @$el.find('[data-model="Client"][data-attribute="name"]').val()
    client = StaffPlan.clients.get(@model.get('client_id'))
    
    unless client?
      client = StaffPlan.clients.detect (client) ->
        client.get("name") is clientNameValue
      
    unless client?
      StaffPlan.addClientByName clientNameValue, (client, reponse) =>
        @addProjectByNameAndClient client
        
    else
      @addProjectByNameAndClient client
    
  addProjectByNameAndClient: (client) ->
    @model.set
      client_id: client.get('id')
    , silent: true
    projectNameValue = @$el.find('[data-model="Project"][data-attribute="name"]').val()
    project = StaffPlan.projects.detect (project) ->
      ( project.get("name") is projectNameValue ) and ( project.get("client_id") is client.get('id') )
    unless project?
      StaffPlan.addProjectByNameAndClient projectNameValue, client, (project, response) =>
        @_save project
    else
      @_save project
  
  _save: (project) =>
    @model.save
      project_id: project.get('id')
      user_id: @user.get('id')
