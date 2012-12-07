class window.StaffPlan.Views.StaffPlans.AssignmentActions extends Backbone.View
  className: "btn-group pull-right"
  tagName: "div"
    
  initialize: ->
    @model.bind 'change', (assignment) =>
      if assignment.changed.proposed? or assignment.changed.archived?
        StaffPlan.router.currentView.trigger('week:updated')
        @render()
      
    @model.work_weeks.bind 'change', (ww) =>
      StaffPlan.router.currentView.trigger('week:updated')
      @render()
    
  render: ->
    @$el.html StaffPlan.Templates.StaffPlans.assignment_actions
      isDeletable: @model.isDeletable()
      proposed: @model.get('proposed')
      archived: @model.get('archived')
    @
  
  leave: ->
    @off()
    @remove()

  events:
    "click a.delete-assignment" : "onDeleteAssignmentClicked"
    "click a.toggle-proposed"   : "onToggleProposedClicked"
    "click a.toggle-archived"   : "onToggleArchivedClicked"
  
  onDeleteAssignmentClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()
    
    @model.destroy()
    @parent.remove()
  
  onToggleProposedClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()
    
    @model.save
      proposed: if @model.get('proposed') then 0 else 1
  
  onToggleArchivedClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()
    
    @model.save
      archived: if @model.get('archived') then 0 else 1
