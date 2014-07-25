class StaffPlan.Views.StaffPlans.ListItem extends Support.CompositeView
  className: "list-item"

  initialize: (options={}) ->
    @parent = options.parent
    @rendered = false
    
    # In this case we simply relay the message to the relevant child view
    @on "date:changed", (message) ->
      @staffplanChartView.trigger "date:changed", message
    
    @on "window:resized", => @render()
      
  events:
    "click .user-info .btn-group a": "handleMembershipAction"

  handleMembershipAction: (event) ->
    event.stopPropagation()
    event.preventDefault()
    target = $(event.target)
    @parent.trigger "membership:toggle"
      userId: @model.id
      action: target.data('action')
      subview: @
  
  renderChart: ->
    @staffplanChartView = new StaffPlan.Views.WeeklyAggregates
      maxHeight: 100
      model: @model
      begin: @parent.startDate
      scaleChart: true
      el: @$el.find("svg.user-chart")
      count: @parent.numberOfBars
      
    @renderChildInto @staffplanChartView, @$el.find "div.chart-container.span10"
  
  renderTotals: ->
    @staffplanTotalsView = new StaffPlan.Views.Shared.Totals
      model: @model
      
    @renderChildInto @staffplanTotalsView, @$el.find "div.totals.fixed-60"
    
  render: ->
    if @rendered
      @renderChart()
    else
      @$el.html HandlebarsTemplates["staffplans/list_item"]
        user: @model.pick ["id", "gravatar", "full_name"]
      
      @renderTotals()
      
      @renderChart()
    
    @rendered = true
    
    @
