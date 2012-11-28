class StaffPlan.Views.StaffPlans.ListItem extends Support.CompositeView
  className: "row-fluid staffplan-list-item list-item"
  initialize: ->
    @startDate = @options.startDate
    @parent = @options.parent
    # In this case we simply relay the message to the relevant child view
    @on "date:changed", (message) ->
      @projectChartView.trigger "date:changed", message

  events:
    "click div.user-info.fixed-180 div.dropdown li a": "handleMembershipAction"

  handleMembershipAction: (event) ->
    event.stopPropagation()
    event.preventDefault()
    target = $(event.target)
    @parent.trigger "membership:toggle"
      userId: @model.id
      action: target.data('action')
      subview: @
  
  render: ->
    @$el.html StaffPlan.Templates.StaffPlans.listItem
      user: @model.pick ["id", "gravatar", "full_name"]
      
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    @numberOfBars = Math.round(chartContainerWidth / 40) - 2
    
    @projectChartView = new StaffPlan.Views.WeeklyAggregates
      maxHeight: 100
      model: @model
      begin: @startDate
      el: @$el.find("svg.user-chart")
      count: @numberOfBars
    @renderChildInto @projectChartView, @$el.find "div.chart-container.span10"

    @
