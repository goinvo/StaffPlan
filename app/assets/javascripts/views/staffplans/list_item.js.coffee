class StaffPlan.Views.StaffPlans.ListItem extends Support.CompositeView
  className: "row-fluid staffplan-list-item list-item"
  initialize: ->
    @startDate = @options.startDate
    @staffplanListItemTemplate = Handlebars.compile @templates.staffplanListItem

  templates:
    staffplanListItem: '''
      <div class='user-info span2' data-user-id="{{user.id}}>
        <a href="/staffplans/{{user.id}}">
          <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
          <span class='name'>
            <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
          </span>
        </a>
        <div class="dropdown">
          <button class="btn btn-mini"><i class="icon-cog"></i></button>
          <button class="btn btn-mini dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></button>
          <ul class="dropdown-menu">
            <li>
              <a href="#" data-action=disable>
                Disable 
              </a>
            </li>
            <li class="divider"></li>
            <li>
              <a href="#" data-action=archive>
                Archive  
              </a>
            </li>
          </ul>
        </div>
      </div>
      <div class="chart-container span10">
        <svg class="user-chart"></svg>
      </div>
    '''
  events:
    "click div.user-info.span2 div.dropdown li a": "handleMembershipAction"

  handleMembershipAction: (event) ->
    event.stopPropagation()
    event.preventDefault()
    target = $(event.target)
    StaffPlan.Dispatcher.trigger "membership:#{target.data('action')}",
      userId: @model.id
      subview: @
  
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
