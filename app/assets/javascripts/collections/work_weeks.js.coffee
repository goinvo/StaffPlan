class window.StaffPlan.Collections.WorkWeeks extends Backbone.Collection
  WEEK_IN_MILLISECONDS: 7 * 24 * 3600 * 1000
  
  model: StaffPlan.Models.WorkWeek
  
  initialize: (models, options) ->
    _.extend @, options

  dateRangeMeta: ->
    @parent.dateRangeMeta()
  
  url: ->
    @parent.url() + "/work_weeks"
  
  between: (begin, end) ->
    weeks = @select (week) ->
      t = week.get "beginning_of_week"
      (t >= begin) and (t < end)
    _.map weeks, (week) -> week.toJSON()

  comparator: (week) ->
    week.get "beginning_of_week"
