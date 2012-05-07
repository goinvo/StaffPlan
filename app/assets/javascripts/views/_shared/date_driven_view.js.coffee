class views.shared.DateDrivenView extends Support.CompositeView
  initialize: ->
    @weekInterval = 15
    @fromDate = moment(window._meta.fromDate)
    @toDate   = @fromDate.clone().add('weeks', @weekInterval)
  
  dateChanged: (event) ->
    event.preventDefault()
    interval = if $(event.currentTarget).data().changePage == 'next' then @weekInterval else -@weekInterval
    @fromDate.add('weeks', interval)
    @toDate.add('weeks', interval)
    
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

    while from < to
      yearsAndWeeks.push
        year:  from.year()
        cweek: +from.format('w')
        month: from.month() + 1
        mweek: +from.format('w')
        mday:  from.date()
        weekHasPassed: from < moment()

      from.add('weeks', 1)
    console.log yearsAndWeeks
    yearsAndWeeks
    
window.views.shared.DateDrivenView = views.shared.DateDrivenView
