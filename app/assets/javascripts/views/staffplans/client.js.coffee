class window.StaffPlan.Views.StaffPlans.Client extends Backbone.View
  className: "client zebra"
  tagName: "section"
    
  initialize: ->
    @model = @options.model
    @user = @options.user
    
    @assignments = new window.StaffPlan.Collections.Assignments @options.assignments || [],
      parent: @
    
    @assignments.map (assignment, index) => @addAssignmentView assignment, index
    
    @assignments.bind 'add', (assignment) =>
      assignment.client = @model
      @addAssignmentView assignment, @assignments.models.length - 1
      @$el.append assignment.view.render().el
    
    @assignments.add() if @model.isNew()
    
    @assignments.bind 'change:id', (assignment) =>
      @model.set('id', assignment.view.client().get('id')) if @model.isNew()
      @$el.attr('data-client-id', @model.get('id'))
      
    @$el.attr('data-client-id', if @model.get('id')? then @model.get('id') else "-1")
    
    @$el.append @assignments.map (assignment) -> assignment.view.el
    
  render: ->
    @assignments.map (assignment) -> assignment.view.render()
    
    @
  
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