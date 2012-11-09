class window.StaffPlan.Collections.WeeklyAggregates extends Backbone.Collection

  model: window.StaffPlan.Models.WeeklyAggregate

  # A collection of aggregates is created for a given date range
  # The parent is whatever is tied to an assignment, can be a project or a user
  # begin and end define the range for which we're actually building aggregates.
  #
  # Could be just the weeks currently being shown or that plus 30 in the
  # past and 30 in the future
  initialize: (models, options) ->
    @parent = options.parent
    @begin = options.begin
    @end = options.end

  populate: () ->
    range = _.range(@begin, @end, 7 * 86400 * 1000)

    # Since we don't actually have data to aggregate for all weeks,
    # we create a dummy week to insert into those "gaps"
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

    # Each work week now transmits its values to the relevant aggregate
    @parent.getAssignments().each (assignment) =>
      assignment.work_weeks.each (week) =>
        t = date.setWeek(week.get('cweek'), week.get('year')).getTime()
        @aggregateWeek(week) if (t >= range[0] and t <= range[range.length - 1])
    @

  # Used by the WeeklyAggregate view.
  # Allows us to scale the charts so that everything is relative to the biggest week
  getBiggestTotal: () ->
    @reduce (biggestTotal, aggregate) ->
      totals = aggregate.get "totals"
      biggestTotal = Math.max(biggestTotal, if (totals.actual > 0) then totals.actual else totals.estimated)
    , 0

  # Update the relevant aggregate with the week's values
  aggregateWeek: (week) ->
    aggregate = @findOrCreateRelevantAggregate week.pick(['cweek', 'year'])
    aggregate.update week.pick(['proposed', 'estimated_hours', 'actual_hours'])

    @

  # For a given week, try to find an existing relevant aggregate and update it
  # If not found, create an empty one and update it
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

  # Keep the collection sorted
  comparator: (first, second) ->
    firstYear = first.get('year')
    secondYear = second.get('year')

    if firstYear == secondYear
      if first.get('cweek') < second.get('cweek') then -1 else 1
    else
      if firstYear < secondYear then -1 else 1
