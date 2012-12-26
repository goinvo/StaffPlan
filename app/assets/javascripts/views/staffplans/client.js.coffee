class window.StaffPlan.Views.StaffPlans.Client extends Support.CompositeView
  className: "client zebra"
  tagName: "section"
    
  initialize: ->
    _.extend @, StaffPlan.Mixins.Events.weeks
    @model = @options.model
    @user = @options.user
    @startDate = @options.startDate
    
    @on "date:changed", (message) => @dateChanged(message.action)
    @on "window:resized", => @onWindowResized()
    
    @assignments = new window.StaffPlan.Collections.Assignments @options.assignments || [],
      parent: @
    
    @assignments.bind 'add', (assignment) => @render()
    
    @assignments.add() if @model.isNew()
    
    @assignments.bind 'change:id', (assignment) =>
      @model.set('id', assignment.client().get('id')) if @model.isNew()
      @$el.attr('data-client-id', @model.get('id'))
    
    @assignments.bind 'change:archived', (assignment) =>
      @assignments.remove assignment,
        silent: true
      
      unless @assignments.any()
        @leave()
      
    @$el.attr('data-client-id', if @model.get('id')? then @model.get('id') else "-1")
    
  render: ->
    @$el.empty()
    
    @assignments.map (assignment, index) =>
      assignmentView = new window.StaffPlan.Views.StaffPlans.Assignment
        model: assignment
        client: @model
        user: @user
        index: index
        startDate: @startDate
      @appendChild assignmentView
    
    @
  
  leave: ->
    @off()
    @remove()

  events:
    "click a.add-project": "onAddProjectClick"
  
  onAddProjectClick: (event) ->
    event.preventDefault()
    event.stopPropagation()
    
    @assignments.add
      user_id: @user.get('id')
      client_id: @model.get('id')
  
  addAssignmentView: (assignment, index) ->
    assignment.view = new window.StaffPlan.Views.StaffPlans.Assignment
      model: assignment
      client: @model
      user: @user
      index: index
