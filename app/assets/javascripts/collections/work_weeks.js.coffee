class window.StaffPlan.Collections.WorkWeeks extends Backbone.Collection
  model: window.StaffPlan.Models.WorkWeek
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
  
  dateRangeMeta: ->
    @parent.dateRangeMeta()
  
  url: ->
    @parent.url() + "/work_weeks"
  
  comparator: (first, second) ->
    firstYear = first.get('year')
    secondYear = second.get('year')
    
    if firstYear == secondYear
      if first.get('cweek') < second.get('cweek') then -1 else 1
    else
      if firstYear < secondYear then -1 else 1