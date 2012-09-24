class window.StaffPlan.Views.Shared.DateDrivenView extends Support.CompositeView
  initialize: ->
    @fromDate = moment.utc().subtract('years', 2)
    
    setTimeout =>
      $( window ).bind 'resize', @onWindowResized
    
  setWeekIntervalAndToDate: ->
    # find first project's work week list, measure the width of its months-and-weeks container
    $container = @$el.find '#interval-width-target'
    $inputContainer = $container.find '.plan-actual:first'
    
    containerWidth = $container.width()
    inputWidth = 35
    
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

  getYearsAndWeeks: (expireCache=false) ->
    if @yearsAndWeeks == undefined || expireCache
      @yearsAndWeeks = []
      
    from = @fromDate.clone()
    to = @toDate.clone()
    
    while from < to
      @yearsAndWeeks.push
        year:  from.year()
        cweek: +from.format('w') # moment is nice but unfortunately doesn't yet provide an .isoWeek function
        month: from.month() + 1 # NOTE: Months in moment.js are 0-indexed
        mweek: +from.format('w') # moment is nice but unfortunately doesn't yet provide an .isoWeek function
        mday:  from.date()
        weekHasPassed: from < moment()

      from.add('weeks', 1)
      
    @yearsAndWeeks
  
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
    #     @renderHeaderTemplate( true )
    #     @renderWeekHourCounter()
    @renderContent( true ) if @renderContent?
    