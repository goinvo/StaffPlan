class window.StaffPlan.Views.StaffPlans.Show extends Support.CompositeView
  className: "staffplan padding-top-272"
  tagName: "div"
  
  events:
    "click a[data-change-page]": "changePage"
    "click a.add-client": "onAddClientClicked"
  
  onAddClientClicked: (event) =>
    event.preventDefault()
    event.stopPropagation()
    
    clientView = new StaffPlan.Views.StaffPlans.Client
      user: @model
    @appendChild clientView
    
  gatherClientsByAssignments: ->
    _.uniq @model.getAssignments().pluck( 'client_id' ).map (clientId) -> StaffPlan.clients.get clientId
    
  initialize: ->
    _.extend @, StaffPlan.Mixins.Events.weeks
    m = moment()
    @startDate = m.utc().startOf('day').subtract('days', m.day() - 1).subtract('weeks', 1)
    
    @debouncedRender = _.debounce =>
      # alert("resize disabled due to a webkit bug that makes all client/assignment rows invisible. reloading the page now.")
      # window.location.reload()
      @render
    , 200
    $(window).bind "resize", (event) =>
      @debouncedRender()
    
    @on "date:changed", (message) => @dateChanged(message.action)
    @on "week:updated", (message) => @staffplanChartView.trigger "week:updated"
    @on "year:changed", (message) => @yearChanged(parseInt(message.year, 10))
    
    @model = @options.user
    @model.view = @
  
  getYearsAndWeeks: ->
    _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    
  changePage: (event) ->
    event.preventDefault()
    event.stopPropagation()
    
    @dateChanged event
  
  render: ->
    @$el.empty()
    
    # staffplan layout
    @$el.append StaffPlan.Templates.StaffPlans.show_frame
      user: @model.attributes
    
    # calculate usable width for inputs
    chartContainerWidth = $(document.body).width() - 510 # padding, margin and width of all other elements besides the flex
    @numberOfBars = Math.round(chartContainerWidth / 39) - 2
    
    # render clients/assignments/inputs
    @gatherClientsByAssignments().map (client) =>
      clientView = new StaffPlan.Views.StaffPlans.Client
        model: client
        user: @model
        assignments: @model.getAssignments().where
          client_id: client.id
        startDate: @startDate
      @appendChild clientView
    
    # chart
    @staffplanChartView = new StaffPlan.Views.WeeklyAggregates
      begin: @startDate.valueOf()
      count: @numberOfBars
      model: @model
      parent: @
      el: @$el.find("svg.user-chart")
      height: 120
      width: chartContainerWidth
    @renderChildInto @staffplanChartView, @$el.find "div.chart-container"
    
    # FY select
    if StaffPlan.relevantYears.length > 2
      @yearFilter = new StaffPlan.Views.Shared.YearFilter
        years: StaffPlan.relevantYears
        parent: @
      @$el.find('div.date-paginator div.fixed-180').append @yearFilter.render().el
      
    # dates and pagination
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
      parent: @
    @renderChildInto dateRangeView, @$el.find "#interval-width-target"
    
    @
  
  leave: ->
    @off()
    @remove()
