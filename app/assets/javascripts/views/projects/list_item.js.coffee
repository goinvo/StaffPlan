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
    @startDate = @options.start
    @model.on "change", (event) =>
      @render()
    @projectListItemTemplate = Handlebars.compile @templates.projectListItem
    
    @$el.html @projectListItemTemplate
      project: @model.toJSON()

  render: ->
    @$el.find("svg.user-chart").empty()
    
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    numberOfBars = Math.round(chartContainerWidth / 40) - 2
    # @aggregates = new StaffPlan.Collections.WeeklyAggregates [],
    #   parent: @model
    #   begin: @startDate.getTime()
    #   end: @startDate.clone().addWeeks(numberOfBars).getTime()
    # @aggregates.populate()
    
    @projectChartView = new StaffPlan.Views.WeeklyAggregates
      maxHeight: 60
      model: @model
      begin: @startDate.getTime()
      count: 36
      el: @$el.find("svg.user-chart")
    @projectChartView.render()

    @
