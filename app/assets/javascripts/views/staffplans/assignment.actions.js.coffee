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
    otherUsers = @model.getProject().getUnassignedUsers().map (user) ->
      fullName: "#{user.get('first_name').charAt(0).toUpperCase()}. #{user.get('last_name')}"
      id: user.get("id")

    @$el.html StaffPlan.Templates.StaffPlans.assignment_actions
      displayReassign: otherUsers.length > 0
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
    "change select[data-action=reassign]": "onReassignClicked"
  
  onReassignClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()
    @model.set "user_id", parseInt($(event.target).val(), 10)
    @model.save()

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
