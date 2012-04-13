class User extends Backbone.Model
  weekInterval: 15

  initialize: (userdata) ->

    @fromDate = new Time().advanceWeeks(-1).beginningOfWeek()
    @toDate   = @fromDate.clone().advanceWeeks @weekInterval

    @projects = new ProjectList @get( "projects" ),
      parent: @

    @view = new views.staffplans.UserView
      model: @
      id: "staffplan_#{@id || @cid}"

    @projects.bind 'add', (project) =>
      projects = @projectsByClient()
      @view.renderProjectsForClient project.get("client_id"), projects[ project.get("client_id") ]

      setTimeout ->
        $(project.view.el).find('input[name="project[name]"]').focus()

    @projects.bind 'project:created', (project) =>
      projects = @projectsByClient()
      @view.renderProjectsForClient project.get("client_id"), projects[ project.get("client_id") ]
      @view.addNewProjectRow()
    
    # Week Hour Counter
    @weekHourCounter = new views.staffplans.ChartTotalsView @, @view.$ ".week-hour-counter"

    $( document.body ).bind 'work_week:value:updated', =>
      @weekHourCounter.render @dateRangeMeta().dates, @projects.models

  urlRoot: "/users"

  dateChanged: (event) ->
    event.preventDefault()
    interval = if $(event.currentTarget).data().changePage == 'next' then @weekInterval else -@weekInterval
    @fromDate.advanceWeeks interval
    @toDate.advanceWeeks   interval
    @view.renderAllProjects()
    @weekHourCounter.render @dateRangeMeta().dates, @projects.models

  dateRangeMeta: ->
    fromDate: @fromDate
    toDate: @toDate
    dates: @getYearsAndWeeks()

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
        projectsByClient[ project.get( 'client_id' ) ] ||= []
        projectsByClient[ project.get( 'client_id' ) ].push project
        projectsByClient
      , {}

  url: ->
    "/users/#{@id}"

@User = User
