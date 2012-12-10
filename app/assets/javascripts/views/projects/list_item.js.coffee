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
    
    @numberOfBars = Math.floor( ($('body').width() - 320) / 40 )
    
    @projectChartView = new StaffPlan.Views.WeeklyAggregates
      maxHeight: 60
      model: @model
      begin: @startDate
      count: @numberOfBars
      el: @$el.find("svg.user-chart")
      
    @renderChildInto @projectChartView, @$el.find "div.chart-container.span10"

    @projectTotalsView = new StaffPlan.Views.Shared.Totals
      model: @model

    @renderChildInto @projectTotalsView, @$el.find "div.totals.fixed-60"

    @
