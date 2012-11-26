class StaffPlan.Views.Assignments.ListItem extends Support.CompositeView
  className: "user-list-item list-item"

  updateWorkWeeksView: (begin) ->
    @workWeeksView.collection = @model.work_weeks.between(begin, begin + @numberOfBars * 7 * 86400 * 1000)
    @workWeeksView.render()
  
  initialize: ->
    @startDate = @options.start.valueOf()
    @userItemTemplate = Handlebars.compile @templates.userItem
    @numberOfBars = @options.numberOfBars
    @on "date:changed", (message) =>
      @workWeeksView.trigger "date:changed", message
  
  render: ->
    @$el.html StaffPlan.Templates.Assignments.userItem
      user: StaffPlan.users.get(@model.get("user_id")).attributes
    @workWeeksView = new window.StaffPlan.Views.Projects.WorkWeeks
      collection: @model.work_weeks
      start: @startDate
      count: @numberOfBars
    @renderChildInto @workWeeksView, @$el.find "div.user-hour-inputs"

    @
  
