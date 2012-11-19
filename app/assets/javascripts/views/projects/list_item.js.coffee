class window.StaffPlan.Views.Projects.ListItem extends Support.CompositeView
  className: "row-fluid project-list-item"
  templates:
    projectListItem: '''
    <div class='project-info span2'>
      <a href="/projects/{{project.id}}">
        {{project.name}}
      </a>
    </div>
    <div class="chart-container span10"> 
      <svg class="user-chart"></svg>
    </div>
    '''

  initialize: ->
    @startDate = @options.start
    @model.on "change", (event) =>
      @render()
    @projectListItemTemplate = Handlebars.compile @templates.projectListItem
    @on "date:changed", (message) ->
      @projectChartView.trigger "date:changed", message
    

  render: ->
    @$el.html @projectListItemTemplate
      project: @model.toJSON()
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
