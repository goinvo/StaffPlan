class StaffPlan.Views.StaffPlans.ListItem extends Support.CompositeView
  className: "row-fluid staffplan-list-item"
  initialize: ->
    @startDate = @options.startDate
    @staffplanListItemTemplate = Handlebars.compile @templates.staffplanListItem
    StaffPlan.Dispatcher.on "date:changed", (message) =>
      @startDate = message.begin
      @render()

  templates:
    staffplanListItem: '''
      <div class='user-info span2'>
        <a href="/staffplans/{{user.id}}">
          <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
          <span class='name'>
            <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
          </span>
        </a>
      </div>
      <div class="chart-container span10">
        <svg class="user-chart"></svg>
      </div>
    '''
  render: ->
    @$el.html @staffplanListItemTemplate
      user: @model.pick ["id", "gravatar", "full_name"]
      
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    @numberOfBars = Math.round(chartContainerWidth / 40) - 2
    
    @projectChartView = new StaffPlan.Views.WeeklyAggregates
      maxHeight: 100
      model: @model
      begin: @startDate
      el: @$el.find("svg.user-chart")
      count: @numberOfBars

    @projectChartView.render()

    @
