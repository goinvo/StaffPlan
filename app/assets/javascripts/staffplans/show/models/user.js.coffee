class User extends Backbone.Model
  weekInterval: 15

  initialize: (userdata) ->

    @fromDate = new Time().advanceDays(-14).beginningOfWeek()
    @toDate   = @fromDate.clone().advanceDays @weekInterval * 7

    @projects = new ProjectList @get( "projects" ),
      parent: @

    @view = new UserView
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
    
    $( document.body ).bind 'work_week:value:updated', =>
      @view.renderWeekHourCounter()

    urlRoot: "/users"

  dateChanged: (event) ->
    event.preventDefault()
    interval = if $(event.currentTarget).data().changePage == 'next' then @weekInterval else -@weekInterval
    @fromDate.advanceDays interval * 7
    @toDate.advanceDays   interval * 7
    @view.renderAllProjects()

  dateRangeMeta: ->
    fromDate: @fromDate
    toDate: @toDate
    dates: @getYearsAndWeeks()

  getYearsAndWeeks: ->
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

      from = from.advanceDays(7)

    yearsAndWeeks

  projectsByClient: ->
    _.reduce @projects.models, (projectsByClient, project) ->
        projectsByClient[ project.get( 'client_id' ) ] ||= []
        projectsByClient[ project.get( 'client_id' ) ].push project
        projectsByClient
      , {}

  url: ->
    "/users/#{@id}"

window.User = User
