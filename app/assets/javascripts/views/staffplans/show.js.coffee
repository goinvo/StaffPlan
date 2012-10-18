class window.StaffPlan.Views.StaffPlans.Show extends window.StaffPlan.Views.Shared.DateDrivenView
  className: "staffplan"
  tagName: "div"
  
  templates:
    frame: '''
    <div id="user-select" class="grid-row user-info padded">
      <div class="grid-row-element fixed-360">
        <img class="gravatar" src="{{user.gravatar}}" />
        <span class='name'>
          <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
        </span>
      </div>
      <div id="user-chart" class="grid-row-element flex chart-totals-view">
        <div class='box'>
          <a class="previous flex">Previous</a>
            <svg id="bar-chart">
            </svg>
          <a class="next flex">Next</a>
        </div>
      </div>
      <div class="grid-row-element"></div>
    </div>
    <div class='header grid-row padded'>
      <div class='grid-row-element fixed-180 title'><span>Client</span></div>
      <div class='grid-row-element fixed-180 title'><span>Project</span></div>
      <div class="grid-row-element flex" id="interval-width-target">dates and shit</div>
    </div>
    '''
  
  gatherClientsByAssignments: ->
    _.uniq @model.assignments.pluck( 'client_id' ).map (clientId) -> StaffPlan.clients.get clientId
    
  initialize: ->
    
    window.StaffPlan.Views.Shared.DateDrivenView.prototype.initialize.call(this)
    
    @model = @options.user
    @model.view = @
    

    
    # a local list of clients for whom this user is assigned projects
    @clients = new StaffPlan.Collections.Clients @gatherClientsByAssignments()
    @clients.bind 'add', (client) =>
      @clientViews.push client.view = new StaffPlan.Views.StaffPlans.Client
        model: client
        user: @model
        assignments: []
      client.view.assignments.add()
      client.view.render()
      @$el.append client.view.el
      
    
    @frameTemplate = Handlebars.compile @templates.frame
    @assignmentTemplate = Handlebars.compile @templates.assignment
    
    @$el.append( @frameTemplate( user: @model.attributes ) )
    
    @$el.append @clientViews = @clients.map (client) =>
      client.view = new StaffPlan.Views.StaffPlans.Client
        model: client
        user: @model
        assignments: @model.assignments.where
          client_id: client.id
    
    
    @$el.append @clientViews.map (clientView) -> clientView.el
  

  render: ->
    @$el.appendTo('section.main')
    @setWeekIntervalAndToDate()
    @clientViews.map (clientView) -> clientView.render()


    ############################ DOESN'T REALLY BELONG HERE #################################
    @aggregates = new window.StaffPlan.Collections.WeeklyAggregates {}, @model
    
    window.StaffPlan.aggregates = @aggregates.populate()

    
    view = new StaffPlan.Views.WeeklyAggregates # Hardwired for now, but works
      cweek: 45
      year: 2012
      numberOfWeeks: 30
      el: @$el.find('svg#bar-chart')
      offsetLeft: @$el.find('section.work-weeks').first().find('input[data-cid][data-attribute]:first').offset().left
      collection: window.StaffPlan.aggregates
    
    #########################################################################################

    @weekHourCounter = new StaffPlan.Views.Shared.ChartTotalsView @dateRangeMeta().dates, _.uniq(_.flatten(@clients.reduce((assignmentArray, client, index, clients) ->
      assignmentArray.push client.view.assignments.models
      assignmentArray
    , [], @)))
    , ".user-select", @$ ".chart-totals-view ul"
    
    setTimeout => @addNewClientAndProjectInputs()
    
    @
  
  addNewClientAndProjectInputs: ->
    @clients.add()
    
  leave: ->
    @off()
    @remove()
