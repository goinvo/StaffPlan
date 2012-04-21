class User extends Backbone.Model
  initialize: (userdata) ->
    @projects = new ProjectList @get( "projects" ),
      parent: @
    
    @work_weeks = new WorkWeekList @get( "work_weeks" ),
      parent: @
    
    # Week Hour Counter (initialised and set in UserView)
    $( document.body ).bind 'work_week:value:updated', =>
      @weekHourCounter.render @dateRangeMeta().dates, @projects.models if @weekHourCounter?

  urlRoot: "/users"

  dateChanged: (event) ->
    event.preventDefault()
    interval = if $(event.currentTarget).data().changePage == 'next' then @weekInterval else -@weekInterval
    @fromDate.advanceWeeks interval
    @toDate.advanceWeeks   interval
    @view.renderAllProjects()
    @weekHourCounter.render @dateRangeMeta().dates, @projects.models

  dateRangeMeta: ->
    @view.dateRangeMeta()

  getYearsAndWeeks: ->
    # XXX Needs caching or memoization badly
    yearsAndWeeks = []
    from = @fromDate.clone()
    to = @toDate.clone()

    while from.isBefore to
      yearsAndWeeks.push
        year:  from.year()
        cweek: from.week()
        month: from.month()
        mweek: from.week()
        mday:  from.day()
        weekHasPassed: from.isBefore new Date

      from = from.advanceWeeks(1)

    yearsAndWeeks

  projectsByClient: ->
    _.reduce @projects.models, (projectsByClient, project) ->
        clientId = project.getClientId()
        projectsByClient[ clientId ] ||= []
        projectsByClient[ clientId ].push project
        projectsByClient
      , {}

class UserList extends Backbone.Collection
  model: User
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
    
  url: ->
    @parent.url() + "/users"

@User = User
@UserList = UserList