class window.StaffPlan.Views.Projects.ListItem extends Backbone.View
  templates:
    projectListItem: '''
    <li class="project-list-item row-fluid" data-project-id="{{project.id}}">
      <div class='project-info span2'>
        <a href="/projects/{{project.id}}">
          {{project.name}}
        </a>
      </div>
      <div class="chart-container span10">
        <svg class="user-chart"></svg>
      </div>
    </li>
    '''

  initialize: ->
    @startDate = new XDate()
    @model.on "change", (event) =>
      @render()
    @projectListItemTemplate = Handlebars.compile @templates.projectListItem

    @aggregates = new StaffPlan.Collections.WeeklyAggregates [],
      parent: @model
      begin: @startDate.getTime()
      end: @startDate.clone().addWeeks(29).getTime()
    
    @aggregates.populate()
    
  render: ->
    @$el.html @projectListItemTemplate
      project: @model.toJSON()
    
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    numberOfBars = Math.round(chartContainerWidth / 40) - 2
    
    @projectChartView = new StaffPlan.Views.WeeklyAggregates
      maxHeight: @aggregates.getBiggestTotal()
      collection: @aggregates#.takeSliceFrom(@startDate.getWeek(), @startDate.getFullYear(), numberOfBars)
      el: @$el.find("svg.user-chart")
      width: chartContainerWidth
    @projectChartView.render()

    @
