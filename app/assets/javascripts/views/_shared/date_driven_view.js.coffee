class views.shared.DateDrivenView extends Support.CompositeView
  initialize: ->
    d = (_.map window._meta.fromDate.split("-"), (elem) -> parseInt(elem, 10)).concat([12, 0, 0, 0])
    @weekInterval = 15
    @fromDate = new Time(d[0], d[1], d[2], d[3], d[4], d[5], d[6])
    @toDate   = @fromDate.clone().advanceWeeks @weekInterval
  
  dateChanged: (event) ->
    event.preventDefault()
    interval = if $(event.currentTarget).data().changePage == 'next' then @weekInterval else -@weekInterval
    @fromDate.advanceWeeks interval
    @toDate.advanceWeeks   interval
    
    @trigger('date:changed')

  dateRangeMeta: ->
    fromDate: @fromDate
    toDate: @toDate
    dates: @getYearsAndWeeks()

  getYearsAndWeeks: ->
    # XXX Needs cacheing or memoization badly
    yearsAndWeeks = []
    from = @fromDate.clone()
    to = @toDate.clone()

    while from.isBefore to
      yearsAndWeeks.push
        year:  from.year()
        cweek: from.week()
        month: from.month()
        mweek: from.week()
        mday:  from.day()
        weekHasPassed: from.isBefore new Date

      from = from.epoch(from.epoch() + 7 * 24 * 3600 * 1000)

    yearsAndWeeks

window.views.shared.DateDrivenView = views.shared.DateDrivenView
