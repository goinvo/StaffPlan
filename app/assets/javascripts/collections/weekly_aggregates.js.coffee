class window.StaffPlan.Collections.WeeklyAggregates extends Backbone.Collection
  
  model: window.StaffPlan.Models.WeeklyAggregate

  initialize: (models, options) ->
    @parent = options.parent

  populate: () ->
    @parent.assignments.each (assignment) =>
      assignment.work_weeks.each (week) =>
        @aggregateWeek(week)
    @
  # NOTE: This function shouldn't be used on sparse collections
  # We SUPPOSE that there are no gaps here, i.e. we use a range to initialize the 
  # collection and fill the gaps with dummy aggregates
  takeSliceFrom: (cweek, year, size) ->
    index = @indexOf @detect (aggregate) ->
      cweek is aggregate.get("cweek") and
        year is aggregate.get("year")
    new StaffPlan.Collections.WeeklyAggregates @models.slice(index, index + size),
      parent: @parent
      
  aggregateWeek: (week) ->
    aggregate = @detect (a) -> _.all ['cweek', 'year'],
      (attr) -> a.get(attr) is week.get(attr)
    unless aggregate?
      aggregate = new StaffPlan.Models.WeeklyAggregate week.pick(['cweek', 'year', 'inFuture'])
      @add aggregate
    
    aggregate.update week.pick(['proposed', 'estimated_hours', 'actual_hours'])

    @
    
  comparator: (first, second) ->
    firstYear = first.get('year')
    secondYear = second.get('year')
    
    if firstYear == secondYear
      if first.get('cweek') < second.get('cweek') then -1 else 1
    else
      if firstYear < secondYear then -1 else 1
