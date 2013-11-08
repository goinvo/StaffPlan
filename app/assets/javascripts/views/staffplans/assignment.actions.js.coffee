class window.StaffPlan.Views.StaffPlans.AssignmentActions extends Support.CompositeView
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
    # The users we can reassign hours to are only people not currently assigned to the project
    otherUsers = @model.getProject().getUnassignedUsers( false ).map (user) ->
      fullName: "#{user.get('first_name').charAt(0).toUpperCase()}. #{user.get('last_name')}"
      id: user.get("id")

    @$el.html StaffPlan.Templates.StaffPlans.assignment_actions
      displayReassign: @model.reAssignable()
      companyUsers: otherUsers
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
    "click ul[data-action=reassign] li a": "onReassignClicked"

  onReassignClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()
    @model.set "user_id", $(event.target).data('user-id')
    @model.save()
    
  
  onDeleteAssignmentClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()
    
    @model.destroy()
    @parent.remove()
    StaffPlan.router.currentView.trigger('assignment:deleted')
  
  onToggleProposedClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()
    
    @model.save
      proposed: not(@model.get("proposed"))
  
  onToggleArchivedClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()
    
    @model.save
      archived: not(@model.get('archived'))
