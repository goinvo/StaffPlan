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
    # _.groupBy weeks, (week) ->
    #   "#{week.get('year')}-#{week.get('cweek')}"

    # groupedByYear = _.groupBy weeks, (week) ->
    #   week.get('year')
    # _.reduce groupedByYear, (memo, weeks, year, obj) ->
    #   groupedByWeek = _.groupBy weeks, (week) ->
    #     week.get('cweek')
    #   memo[year] = _.map groupedByWeek, (weeks, week)
    #     , {}

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

    weeks = _.flatten (@model.assignments.map (assignment) ->
      assignment.work_weeks.select (elem) ->
        (elem.get('year') is 2012) and (elem.get('cweek') is 32))
    
    @aggregate = new StaffPlan.Models.WeeklyAggregate(collection: weeks, year: 2012, cweek: 32)
    
    console.log @aggregate
    # allWeeks = _.flatten @model.assignments.map (ass) ->
    #     ass.work_weeks.models
    
    # groupedByYearCweek = _.groupBy allWeeks, (w) ->
    #   "#{w.get 'year'}-#{w.get 'cweek'}"
    


    @
  
  addNewClientAndProjectInputs: ->
    @clients.add()
    
  leave: ->
    @off()
    @remove()
