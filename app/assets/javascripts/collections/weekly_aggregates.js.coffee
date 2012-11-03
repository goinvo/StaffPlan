class window.StaffPlan.Collections.WeeklyAggregates extends Backbone.Collection
  
  model: window.StaffPlan.Models.WeeklyAggregate

  initialize: (models, options) ->
    @parent = options.parent

  populate: () ->
    # Fill the gaps...
    begin = new XDate()
    # The number of weeks we add should be increased but too computationally expensive :/
    end = begin.clone().addWeeks(30)
    date = new XDate()
    
    _.each _.range(begin.getTime(), end.getTime(), 7 * 24 * 3600 * 1000), (timestamp) =>
      date.setTime(timestamp)
      @findOrCreateRelevantAggregate
        cweek: date.getWeek()
        year: date.getFullYear()

    @parent.getAssignments().each (assignment) =>
      assignment.work_weeks.each (week) =>
        @aggregateWeek(week)
    @
  takeSliceFrom: (cweek, year, size) ->
    index = @indexOf @detect (aggregate) ->
      cweek is aggregate.get("cweek") and
        year is aggregate.get("year")
    new StaffPlan.Collections.WeeklyAggregates @models.slice(index, index + size),
      parent: @parent

  getBiggestTotal: () ->
    @reduce (biggestTotal, aggregate) ->
      totals = aggregate.get "totals"
      biggestTotal = Math.max(biggestTotal, if (totals.actual > 0) then totals.actual else totals.estimated)
    , 0
      
  aggregateWeek: (week) ->
    aggregate = @findOrCreateRelevantAggregate week.pick(['cweek', 'year'])
    aggregate.update week.pick(['proposed', 'estimated_hours', 'actual_hours'])

    @
    
  findOrCreateRelevantAggregate: (week) ->
    aggregate = @detect (a) -> _.all ['cweek', 'year'],
      (attr) -> a.get(attr) is week[attr]
    unless aggregate?
      aggregate = new StaffPlan.Models.WeeklyAggregate _.extend week,
        proposed: false
        actual_hours: 0
        estimated_hours: 0
      
      @add aggregate

    aggregate

  comparator: (first, second) ->
    firstYear = first.get('year')
    secondYear = second.get('year')
    
    if firstYear == secondYear
      if first.get('cweek') < second.get('cweek') then -1 else 1
    else
      if firstYear < secondYear then -1 else 1
