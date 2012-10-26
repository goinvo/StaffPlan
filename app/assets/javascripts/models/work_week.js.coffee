class window.StaffPlan.Models.WorkWeek extends Backbone.Model
  
  hasPassedOrIsCurrent: (fromDate=@collection.parent.view.user.view.fromDate) ->
    (@get('year') < fromDate.getUTCFullYear() ||
    ((@get('cweek') == fromDate.getWeek() && @get('year') == fromDate.getUTCFullYear()) || (@get('cweek') <= fromDate.getWeek() && @get('year') <= fromDate.getUTCFullYear())))
    
  
  isToday:  (fromDate=@collection.parent.view.user.view.fromDate) ->
    fromDate.getWeek() == @get('cweek') && fromDate.getUTCFullYear() == @get('year')

  pick: (attrs) ->
    _.reduce attrs, (memo, elem) =>
      if typeof this[elem] is "function"
        memo[elem] = this[elem].apply(@)
      else
        memo[elem] = @get elem
      memo
    , {}

  hasPassed: ->
    d = new XDate()
    timeAtBeginningOfCurrentWeek = d.setWeek(d.getWeek()).getTime()
    timeAtBeginningOfWeek = new XDate().setWeek(@get("cweek"), @get("year")).getTime()
    
    if timeAtBeginningOfCurrentWeek > timeAtBeginningOfWeek
      1
    else
      if timeAtBeginningOfCurrentWeek < timeAtBeginningOfWeek
        -1
      else
        0
