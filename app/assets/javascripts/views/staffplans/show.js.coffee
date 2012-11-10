class window.StaffPlan.Views.StaffPlans.Show extends window.StaffPlan.Views.Shared.DateDrivenView
  className: "staffplan"
  tagName: "div"
  
  events:
    "click a[data-change-page]": "changePage"
    "click a.add-client": "onAddClientClicked"
  
  onAddClientClicked: ->
    @clients.add()
    @$el.append @clients.last().view.render().el
    
  gatherClientsByAssignments: ->
    _.uniq @model.getAssignments().pluck( 'client_id' ).map (clientId) -> StaffPlan.clients.get clientId
    
  initialize: ->
    window.StaffPlan.Views.Shared.DateDrivenView.prototype.initialize.call(this)
    
    key 'left, right', (event) => @changePage( event )
    @bind 'date:changed', => @render()
      
    @model = @options.user
    @model.view = @
    
    # a local list of clients for whom this user is assigned projects
    @clients = new StaffPlan.Collections.Clients
    @clients.bind 'add', (client) => @addViewToClient client
    @clients.reset @gatherClientsByAssignments()
    @clients.map (client) => @addViewToClient client
    
    @$el.append StaffPlan.Templates.StaffPlans.show_frame
      user: @model.attributes
    
    
    @$el.append @clients.map (client) -> client.view.el
  
  addViewToClient: (client) ->
    client.view = new StaffPlan.Views.StaffPlans.Client
      model: client
      user: @model
      assignments: @model.getAssignments().where
        client_id: client.id
    
  changePage: (event) -> @dateChanged event
  
  render: ->
    if @$el.closest('html').length == 0
      # first render
      @$el.appendTo('section.main')
      @setWeekIntervalAndToDate()
      @weekHourCounter = new StaffPlan.Views.Shared.ChartTotalsView @dateRangeMeta().dates, _.uniq(_.flatten(@clients.reduce((assignmentArray, client, index, clients) ->
        assignmentArray.push client.view.assignments.models
        assignmentArray
      , [], @)))
      , "#user-chart", @$ ".chart-totals-view ul"
    
    else
      # re-render
      @weekHourCounter.render @dateRangeMeta().dates, _.uniq(_.flatten(@clients.reduce((assignmentArray, client, index, clients) ->
        assignmentArray.push client.view.assignments.models
        assignmentArray
      , [], @)))
    
    @$el.find( '.date-range-target' ).html StaffPlan.Templates.StaffPlans.show_workWeeksAndYears
      dates: @dateRangeMeta().dates
    
    @clients.map (client) -> client.view.render()

    @weekHourCounter = new StaffPlan.Views.Shared.ChartTotalsView @dateRangeMeta().dates, _.uniq(_.flatten(@clients.reduce((assignmentArray, client, index, clients) ->
      assignmentArray.push client.view.assignments.models
      assignmentArray
    , [], @)))
    , "#user-chart", @$ ".chart-totals-view ul"
    
    @
  
  leave: ->
    @off()
    @remove()
