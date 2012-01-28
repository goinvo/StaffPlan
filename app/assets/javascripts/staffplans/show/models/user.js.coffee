class User extends Backbone.Model
  weekInterval: 15

  initialize: (userdata) ->

    @fromDate = Date.today().addWeeks(-2).moveToDayOfWeek Date.getDayNumberFromName 'Monday', -1
    @toDate   = @fromDate.clone().addWeeks @weekInterval

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
    @fromDate.addWeeks interval
    @toDate.addWeeks   interval
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
        year: from.getFullYear()
        cweek: from.getISOWeek()
        month: from.getMonth()
        mweek: from.getWeek()
        weekHasPassed: from.isBefore Date.today()

      from = from.add(1).week()

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
