class StaffPlan.Views.Assignments.ListItem extends Support.CompositeView
  className: "user-list-item list-item"

  updateWorkWeeksView: (begin) ->
    @workWeeksView.collection = @model.work_weeks.between(begin, begin + @numberOfBars * 7 * 86400 * 1000)
    @workWeeksView.render()
  
  initialize: ->
    @startDate = @options.start.valueOf()
    @numberOfBars = @options.numberOfBars
    @on "date:changed", (message) =>
      @workWeeksView.trigger "date:changed", message
  
  render: ->
    @$el.html StaffPlan.Templates.Assignments.userItem
      user: StaffPlan.users.get(@model.get("user_id")).attributes

    @actionsView = new window.StaffPlan.Views.StaffPlans.AssignmentActions
      model: @model
      parent: @
    @renderChildInto @actionsView, @$el.find "div.user-info div.assignment-actions"

    @workWeeksView = new window.StaffPlan.Views.Projects.WorkWeeks
      collection: @model.work_weeks
      start: @startDate
      count: @numberOfBars
    @renderChildInto @workWeeksView, @$el.find "div.user-hour-inputs"


    @assignmentTotalsView = new StaffPlan.Views.StaffPlans.AssignmentTotals
      model: @model
      parent: @
    @renderChildInto @assignmentTotalsView, @$el.find "div.totals.fixed-60"

    @
  
