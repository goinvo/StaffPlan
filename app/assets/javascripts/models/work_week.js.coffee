class window.StaffPlan.Models.WorkWeek extends StaffPlan.Model
  
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
    
  inFuture: ->
    d = new XDate()
    timeAtBeginningOfCurrentWeek = new XDate().setWeek(d.getWeek(), d.getFullYear()).getTime()
    timeAtBeginningOfWeek = new XDate().setWeek(@get("cweek"), @get("year")).getTime()
    
    timeAtBeginningOfWeek > timeAtBeginningOfCurrentWeek
