class window.StaffPlan.Views.StaffPlans.AssignmentActions extends Backbone.View
  className: "btn-group pull-right"
  tagName: "div"
    
  initialize: ->
    @assignment = @options.assignment
    
    @assignment.model.bind 'change', (assignment) =>
      if assignment.changed.proposed? or assignment.changed.archived?
        StaffPlan.router.currentView.trigger('week:updated')
        @render()
      
    @assignment.model.work_weeks.bind 'change', (ww) =>
      @render()
    
  render: ->
    @$el.html StaffPlan.Templates.StaffPlans.assignment_actions
      isDeletable: @assignment.isDeletable()
      proposed: @assignment.model.get('proposed')
      archived: @assignment.model.get('archived')
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
    
    @assignment.model.destroy()
    @assignment.remove()
  
  onToggleProposedClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()
    
    @assignment.model.save
      proposed: if @assignment.model.get('proposed') then 0 else 1
  
  onToggleArchivedClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()
    
    @assignment.model.save
      archived: if @assignment.model.get('archived') then 0 else 1
