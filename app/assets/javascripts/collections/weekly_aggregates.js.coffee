class window.StaffPlan.Collections.WeeklyAggregates extends Backbone.Collection

  model: window.StaffPlan.Models.WeeklyAggregate

  initialize: (models, options) ->
    @parent = options.parent
    @begin = options.begin
    @end = options.end

  populate: () ->
    range = _.range(@begin, @end, 7 * 86400 * 1000)

    baseAggregate = new StaffPlan.Models.WeeklyAggregate
      cweek: 0
      year: 0
      timestamp: 0
      totals:
        estimated: 0
        actual: 0
        proposedEstimated: 0
        proposedActual: 0
    date = new XDate()
    dummies = range.map (timestamp) ->
      dateClone = date.clone().setTime(timestamp)
      baseAggregate.clone().set
        cweek: dateClone.getWeek()
        year: dateClone.getFullYear()
        timestamp: timestamp
    @add dummies

    @parent.getAssignments().each (assignment) =>
      assignment.work_weeks.each (week) =>
        t = date.setWeek(week.get('cweek'), week.get('year')).getTime()
        @aggregateWeek(week) if (t >= range[0] and t <= range[range.length - 1])
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
