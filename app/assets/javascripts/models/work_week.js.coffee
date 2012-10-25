class window.StaffPlan.Models.WorkWeek extends Backbone.Model    
  toCriteria: =>
    year: @get("year")
    cweek: @get("cweek")
  
  hasPassedOrIsCurrent: (fromDate=@collection.parent.view.user.view.fromDate) ->
    (@get('year') < fromDate.getUTCFullYear() ||
    ((@get('cweek') == fromDate.getWeek() && @get('year') == fromDate.getUTCFullYear()) || (@get('cweek') <= fromDate.getWeek() && @get('year') <= fromDate.getUTCFullYear())))
    
  
  isToday:  (fromDate=@collection.parent.view.user.view.fromDate) ->
    fromDate.getWeek() == @get('cweek') && fromDate.getUTCFullYear() == @get('year')

  hasPassedOrIsCurrent: (fromDate=@collection.parent.view.user.view.fromDate) ->
    (@get('year') < fromDate.getUTCFullYear() ||
    ((@get('cweek') == fromDate.getWeek() && @get('year') == fromDate.getUTCFullYear()) || (@get('cweek') <= fromDate.getWeek() && @get('year') <= fromDate.getUTCFullYear())))