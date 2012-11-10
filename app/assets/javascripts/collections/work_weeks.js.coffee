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
    date = new XDate()
    weeks = @select (week) ->
      date.setWeek(week.get("cweek"), week.get("year"))
      time = date.getTime()
      (time > begin) and (time < end)
    _.map weeks, (week) -> week.toJSON()

  comparator: (first, second) ->
    firstYear = first.get('year')
    secondYear = second.get('year')
    
    if firstYear == secondYear
      if first.get('cweek') < second.get('cweek') then -1 else 1
    else
      if firstYear < secondYear then -1 else 1
