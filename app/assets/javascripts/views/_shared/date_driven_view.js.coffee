class views.shared.DateDrivenView extends Support.CompositeView
  initialize: ->
    @fromDate = moment(window._meta.fromDate)
    
    # default to show 3 months, we'll defer re-rendering the proper
    # amount until we have something to measure in the DOM
    @weekInterval = 15
    @toDate = @fromDate.clone().add('weeks', @weekInterval)
    setTimeout @delayedOnWindowResized, 100
    
    $( window ).bind 'resize', @onWindowResized
    
  setWeekIntervalAndToDate: ->
    # find first project's work week list, measure the width of its months-and-weeks container
    
    $container = $( @container_selector )
    $inputContainer = $container.find( '.plan-actual:first' )
    
    if $inputContainer.length == 0
      @onWindowResized()
      return
    
    containerWidth = $container.width()
    inputWidth = $container.find( '.plan-actual div:not(.row-label):first' ).first().width()
    
    # 105 accounts for plan/actual labels, totals and delta/remove icons
    idealWeekInterval = Math.floor ( containerWidth - 105 ) / inputWidth
    
    # in an ideal world, weekInterval is now how many elements we'd show.  Real world:
    # there's ~3px of junk space between input elements that we need to account for and adjust
    mysterySpace = idealWeekInterval * 3
    @weekInterval = idealWeekInterval - Math.ceil( mysterySpace / 35 )
    
    @toDate = @fromDate.clone().add('weeks', @weekInterval)
    
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
    yearsAndWeeks = []
    from = @fromDate.clone()
    to = @toDate.clone()

    while from < to
      yearsAndWeeks.push
        year:  from.isoyear()
        cweek: from.isoweek() 
        month: from.month() + 1 # NOTE: Months in moment.js are 0-indexed
        mweek: from.isoweek()
        mday:  from.date()
        weekHasPassed: from < moment()

      from.add('weeks', 1)
    yearsAndWeeks
  
  onWindowResized: (event) =>
    if event == undefined
      @stopOnNextNullEvent = true
    
    if @stopOnNextNullEvent
      return
      
    if @windowResizedTimeout?
      window.clearTimeout @windowResizedTimeout
      @windowResizedTimeout = undefined
    
    @windowResizedTimeout = window.setTimeout =>
      @delayedOnWindowResized()
    , 200
  
  delayedOnWindowResized: =>
    @setWeekIntervalAndToDate()
    @renderHeaderTemplate( true )
    @renderWeekHourCounter()
    @renderContent( true ) if @renderContent?
    
window.views.shared.DateDrivenView = views.shared.DateDrivenView
