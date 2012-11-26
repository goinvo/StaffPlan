class window.StaffPlan.Views.Projects.ListItem extends Support.CompositeView
  className: "project-list-item list-item"

  initialize: ->
    @startDate = @options.start
    @model.on "change", (event) =>
      @render()
    
    @on "date:changed", (message) ->
      @projectChartView.trigger "date:changed", message
    

  render: ->
    @$el.html StaffPlan.Templates.Projects.index.listItem
      project: @model.toJSON()
      client: StaffPlan.clients.get(@model.get('client_id')).toJSON()
    @$el.find("svg.user-chart").empty()
    
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    @numberOfBars = Math.round(chartContainerWidth / 40) - 2
    
    @projectChartView = new StaffPlan.Views.WeeklyAggregates
      maxHeight: 60
      model: @model
      begin: @startDate
      count: @numberOfBars
      el: @$el.find("svg.user-chart")
    @renderChildInto @projectChartView, @$el.find "div.chart-container.span10"


    @
