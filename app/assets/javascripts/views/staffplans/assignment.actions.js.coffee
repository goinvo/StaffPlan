class window.StaffPlan.Views.StaffPlans.AssignmentActions extends Backbone.View
  className: "btn-group pull-right"
  tagName: "div"
    
  initialize: ->
    @assignment = @options.assignment
    
    @assignment.model.work_weeks.bind 'change:actual_hours', (ww) => @render()
    
  render: ->
    @$el.html StaffPlan.Templates.StaffPlans.assignment_actions
      isDeletable: @assignment.isDeletable()
      proposed: @assignment.model.get('proposed')
      archived: @assignment.model.get('archived') || false
    @
  
  events:
    "click a.delete-assignment": "onDeleteAssignmentClicked"
  
  onDeleteAssignmentClicked: (event) ->
    @assignment.model.destroy()
    @assignment.remove()