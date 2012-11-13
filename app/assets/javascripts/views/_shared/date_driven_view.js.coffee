class window.StaffPlan.Views.Shared.DateDrivenView extends Support.CompositeView
  initialize: ->
     
    @fromDate = moment.utc().startOf('week').startOf('day').subtract("weeks", 2) # move back two weeks to start
    
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
    
    if event.type == "keydown"
      interval = if event.keyIdentifier.toLowerCase() == 'right' then @weekInterval else -@weekInterval
    else
      interval = if $(event.target).data().changePage == 'next' then @weekInterval else -@weekInterval
    
    @fromDate.add('weeks', interval)
    @toDate.add('weeks', interval)
    
    @trigger('date:changed')

  dateRangeMeta: ->
    fromDate: @fromDate
    toDate: @toDate
    dates: @getYearsAndWeeks()

  getYearsAndWeeks: ->
    _.range(@fromDate.valueOf(), @fromDate.valueOf() + @weekInterval * 7 * 86400 * 1000, 7 * 86400 * 1000)
  
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
    
