class window.StaffPlan.Views.StaffPlans.Show extends StaffPlan.View
  className: "staffplan-show tall"
  
  events:
    "click a[data-change-page]": "changePage"
    "click a.add-client": "onAddClientClicked"
    "change input[data-model=\"Client\"]": "updateProjectTypeAheadOptionList"
    "blur input[data-model=\"Client\"]": "updateProjectTypeAheadOptionList"
  
  updateProjectTypeAheadOptionList: (event) ->
    clientName = $(event.target).val()
    client = StaffPlan.clients.detect (client) ->
      client.get('name') is clientName
    if client?
      @$el.find("input[data-model=\"Project\"]").data('typeahead').source = client.getProjects().pluck("name")

  onAddClientClicked: (event) =>
    event.preventDefault()
    event.stopPropagation()
    
    clientView = new StaffPlan.Views.StaffPlans.Client
      user: @model
      model: new StaffPlan.Models.Client()
      
    @appendChildTo clientView, $('section.main')
    
    @$el.find('input[data-model="Client"]').typeahead
      source: StaffPlan.clients.pluck 'name'
      items: 12
    
    @$el.find('input[data-model="Project"]').typeahead
      source: StaffPlan.projects.pluck 'name'
      items: 12
    
  gatherClientsByAssignments: ->
    _.uniq @model.getAssignments().select((assignment) -> !assignment.get('archived')).map((assignment) -> assignment.get('client_id')).map (clientId) -> StaffPlan.clients.get clientId
    
  initialize: ->
    _.extend @, StaffPlan.Mixins.Events.weeks
    m = moment()
    @startDate = m.utc().startOf('day').subtract('days', m.day() - 1).subtract('weeks', 1)
    
    key "left, right", (event) =>
      @dateChanged if event.keyIdentifier.toLowerCase() is "left" then "previous" else "next"

    @debouncedRender = _.debounce =>
      @calculateNumberOfBars()
      @renderDatesAndPagination()
      @renderChart()
      @onWindowResized()
    , 200
    
    $(window).bind "resize", (event) => @debouncedRender()
    
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
  
  calculateNumberOfBars: ->
    # calculate usable width for inputs
    @chartContainerWidth = $(document.body).width() - 520 # padding, margin and width of all other elements besides the flex
    @numberOfBars = Math.round(@chartContainerWidth / 39) - 2
  
  renderChart: ->
    # chart
    @staffplanChartView = new StaffPlan.Views.WeeklyAggregates
      begin: @startDate.valueOf()
      count: @numberOfBars
      model: @model
      parent: @
      el: @$el.find("svg.user-chart")
      height: 120
      width: @chartContainerWidth
    @renderChildInto @staffplanChartView, @$el.find "div.chart-container"
    
  renderDatesAndPagination: ->
    # dates and pagination
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
      parent: @
    @renderChildInto dateRangeView, @$el.find "#interval-width-target"
    
  renderClientsAssignmentsWorkWeeks: ->
    # render clients/assignments/inputs
    @gatherClientsByAssignments().map (client) =>
      clientView = new StaffPlan.Views.StaffPlans.Client
        model: client
        user: @model
        assignments: @model.getAssignments().where
          archived: false
          client_id: client.id
        startDate: @startDate
      @appendChildTo clientView, @$el.find "section.main"
      
  renderStaffPlanFrame: ->
    # staffplan layout
    @$el.find('header').append StaffPlan.Templates.StaffPlans.show_frame
      user: @model.attributes
  
  renderFYSelect: ->
    # FY select
    if StaffPlan.relevantYears.length > 2
      @yearFilter = new StaffPlan.Views.Shared.YearFilter
        years: StaffPlan.relevantYears
        parent: @
      @$el.find('header .inner ul:first').append @yearFilter.render().el
  
  render: ->
    super
    
    @renderStaffPlanFrame()
    
    @calculateNumberOfBars()
    
    @renderClientsAssignmentsWorkWeeks()
    
    @renderDatesAndPagination()
    
    @renderChart()
    
    @renderFYSelect()
    
    m = moment()
    timestampAtBeginningOfWeek = m.utc().startOf('day').subtract('days', m.day() - 1)

    @

