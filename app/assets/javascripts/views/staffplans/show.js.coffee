class window.StaffPlan.Views.StaffPlans.Show extends window.StaffPlan.Views.Shared.DateDrivenView
  className: "staffplan"
  tagName: "div"
  
  templates:
    frame: '''
    <div id="user-select" class="grid-row user-info">
      <div class="grid-row-element fixed-360">
        <img class="gravatar" src="{{user.gravatar}}" />
        <span class='name'>
          <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
        </span>
      </div>
      <div id="user-chart" class="grid-row-element flex"></div>
      <div class="grid-row-element"></div>
    </div>
    <div class='header grid-row padded'>
      <div class='grid-row-element fixed-180 title'><span>Client</span></div>
      <div class='grid-row-element fixed-180 title'><span>Project</span></div>
      <div class="grid-row-element flex" id="interval-width-target">some stuff about dates or something</div>
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
  
  # ################################################# #
  # FIXME: /!\ Kind of stupid, find a better way /!\  #
  # ################################################# #
  getWeekSpan: ->
    grouped = @model.assignments.map (a) ->
      _.groupBy a.work_weeks.models, (week) ->
        "#{week.get("year")}-#{week.get("cweek")}"
        
    weeks = _.uniq _.flatten _.map grouped, (a) ->
      _.keys a
    
    _.map weeks, (week) ->
      [year, cweek] = _.map week.split("-"), (n) ->
        parseInt n, 10
      year: year
      cweek: cweek

  getHoursForWeek: (criteria) ->
    _.flatten @model.assignments.map (assignment) ->
      assignment.work_weeks.where criteria

  createAggregates: =>
    _.map @getWeekSpan(), (week) =>
      new StaffPlan.Models.WeeklyAggregate
        weeks: @getHoursForWeek(week)
        year: week.year
        cweek: week.cweek

  render: ->
    @$el.appendTo('section.main')
    @setWeekIntervalAndToDate()
    @clientViews.map (clientView) -> clientView.render()

    

    aggregatesView = new StaffPlan.Views.WeeklyAggregates
      collection: new Backbone.Collection(@createAggregates())
      cweek: 23
      year: 2012
      numberOfWeeks: 16

    @
  
  addNewClientAndProjectInputs: ->
    @clients.add()
    
  leave: ->
    @off()
    @remove()
