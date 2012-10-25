class window.StaffPlan.Views.Shared.DateDrivenView extends Support.CompositeView
  initialize: ->
    today = new XDate().addDays(5)
    if today.getDay() == 0 # sunday
      today = today.addDays(-6)
    else if today.getDay() > 1
      while today.getDay() > 1
        today = today.addDays(-1)
    
    @fromDate = today.addWeeks(-2) # move back two weeks to start
    
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
    @toDate = @fromDate.clone().addWeeks(@weekInterval)
    
  dateChanged: (event) ->
    event.preventDefault()
    
    if event.type == "keydown"
      interval = if event.keyIdentifier.toLowerCase() == 'right' then @weekInterval else -@weekInterval
    else
      interval = if $(event.currentTarget).data().changePage == 'next' then @weekInterval else -@weekInterval
    
    @fromDate.addWeeks(interval)
    @toDate.addWeeks(interval)
    
    @trigger('date:changed')

  dateRangeMeta: ->
    fromDate: @fromDate
    toDate: @toDate
    dates: @getYearsAndWeeks()

  getYearsAndWeeks: ->
    @yearsAndWeeks = []
      
    from = @fromDate.clone()
    to = @toDate.clone()
    
    while from < to
      @yearsAndWeeks.push
        xdate:  new XDate(from)
        year:  from.getUTCFullYear()
        cweek: from.getWeek()
        month: from.getMonth() + 1 # NOTE: Months in moment.js are 0-indexed
        mday:  from.getDate()
        weekHasPassed: from < XDate()

      from.addWeeks(1)
      
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
    @render()
    
