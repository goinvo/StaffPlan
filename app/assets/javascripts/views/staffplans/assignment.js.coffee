class window.StaffPlan.Views.StaffPlans.Assignment extends Backbone.View
  className: "assignment-row grid-row padded"
  tagName: "div"
  
  project: ->
    StaffPlan.projects.get( @model.get 'project_id' )
    
  client: ->
    StaffPlan.clients.get( @project()?.get('client_id') )
    
  leave: -> 
    @off()
    @remove()

  initialize: ->
    @model = @options.model
    @user = @options.user
    @index = @options.index
    
    @$el.data('cid', @cid)
    
    @model.bind 'change:id', => @render()
    
    @assignmentTotalsView = new StaffPlan.Views.StaffPlans.AssignmentTotals
      assignment: @
    @workWeeksView = new window.StaffPlan.Views.StaffPlans.WorkWeeks
      collection: @model.work_weeks
      user: @user

  ensureWorkWeekRange: =>
    # pads this assignment's work weeks for the selected date range adding new WorKWeek objects where needed so all inputs are rendered.
    for timestamp in @user.view.getYearsAndWeeks()
      unless (@model.work_weeks.detect (week) -> timestamp is week.get("beginning_of_week"))
        @model.work_weeks.add
          beginning_of_week: timestamp

  isDeletable: ->
    !@model.work_weeks.any (ww) -> ww.get('actual_hours')? && ww.get('actual_hours') > 0
    
  render: ->
    if @model.isNew()
      @$el.html StaffPlan.Templates.StaffPlans.assignment_new
        showClientInput: @model.client.isNew()
        
    else
      @$el.html StaffPlan.Templates.StaffPlans.assignment_show
        showAddProject: @index == 0
        clientName: if @index == 0 then @client().get('name') else ""
        projectName: @project()?.get('name')
        user_id: @user.id
        isDeletable: @isDeletable()
    
      @ensureWorkWeekRange()
      
      @assignmentActionsView = new StaffPlan.Views.StaffPlans.AssignmentActions
        assignment: @
        
      # We should set the views' element to the following HTML elements instead
      # That way you just render() every view and it does the same thing automatically
      @$el.find( '.assignment-actions-target' ).append @assignmentActionsView.render().el
      @$el.find( 'div.work-weeks' )
        .append(@workWeeksView.render().el)
      @$el.append(@assignmentTotalsView.render().el)
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
      target_user_id: @user.get('id')
