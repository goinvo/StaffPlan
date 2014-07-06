class StaffPlan.Views.Assignments.ListItem extends Support.CompositeView
  className: "user-list-item list-item"

  updateWorkWeeksView: (begin) ->
    @workWeeksView.collection = @model.work_weeks.between(begin, begin + @numberOfBars * 7 * 86400 * 1000)
    @workWeeksView.render()
  
  initialize: (options={}) ->
    @parent = options.parent
    @model.collection.on "change:user_id", (event) => @render()
    @startDate = options.start.valueOf()

    @on "date:changed", (message) =>
      @workWeeksView.trigger "date:changed", message
  
  render: ->
    if _.isNumber @model.get("user_id")
      @$el.html StaffPlan.Templates.Assignments.userItem
        user: StaffPlan.users.get(@model.get("user_id")).attributes
    else
      @$el.html StaffPlan.Templates.Assignments.userItem
        user:
          id: 0
          gravatar: "https://secure.gravatar.com/avatar/ee56924c10943ba1af0e004b90f3a095"
          first_name: "TBD"
          last_name: ""
    @actionsView = new StaffPlan.Views.StaffPlans.AssignmentActions
    
      model: @model
      parent: @
    @renderChildInto @actionsView, @$el.find "div.user-info div.assignment-actions"

    @workWeeksView = new window.StaffPlan.Views.Projects.WorkWeeks
      collection: @model.work_weeks
      start: @startDate
      count: @parent.numberOfBars
    @renderChildInto @workWeeksView, @$el.find "div.user-hour-inputs"


    @assignmentTotalsView = new StaffPlan.Views.StaffPlans.AssignmentTotals
      model: @model
      parent: @
    @renderChildInto @assignmentTotalsView, @$el.find "div.totals.fixed-60"

    @
  
