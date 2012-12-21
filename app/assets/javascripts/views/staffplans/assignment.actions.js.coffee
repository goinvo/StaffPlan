class window.StaffPlan.Views.StaffPlans.AssignmentActions extends Support.CompositeView
  className: "btn-group pull-right"
  tagName: "div"
    
  initialize: ->
    @model.bind "change:user_id", (assignment) =>
      @parent.remove()
    @model.bind 'change', (assignment) =>
      if assignment.changed.proposed? or assignment.changed.archived?
        StaffPlan.router.currentView.trigger('week:updated')
        @render()
      
    @model.work_weeks.bind 'change', (ww) =>
      StaffPlan.router.currentView.trigger('week:updated')
      @render()
    
  render: ->
    companyUsers = StaffPlan.users.map (user) -> user.pick ["id", "first_name", "last_name"]
    @$el.html StaffPlan.Templates.StaffPlans.assignment_actions
      companyUsers: companyUsers
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
    "click a[data-action=reassign]": "onReassignClicked"
  
  onReassignClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()
    @model.save
      user_id: $(event.target).data('user-id')

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
