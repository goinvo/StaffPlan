class window.StaffPlan.Collections.WeeklyAggregates extends Backbone.Collection
  
  model: window.StaffPlan.Models.WeeklyAggregate

  initialize: (models, options) ->
    @parent = options.parent

  populate: () ->
    @parent.assignments.each (assignment) =>
      assignment.work_weeks.each (week) =>
        @aggregateWeek(week)
    @
  
      
  aggregateWeek: (week) ->
    aggregate = @detect (a) -> _.all ['cweek', 'year'], 
      (attr) -> a.get(attr) is week.get(attr)
    unless aggregate?
      aggregate = new StaffPlan.Models.WeeklyAggregate week.pick(['cweek', 'year', 'hasPassed'])
      @add aggregate
    
    aggregate.update week.pick(['proposed', 'estimated_hours', 'actual_hours'])

    @
    
  comparator: (first, second) ->
    firstYear = first.year
    secondYear = second.year
    
    if firstYear == secondYear
      if first.cweek < second.cweek then -1 else 1
    else
      if firstYear < secondYear then -1 else 1
