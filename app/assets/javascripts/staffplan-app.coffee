window.StaffPlan =
  Models: {}
  Collections: {}
  Templates: {}
  Mixins:
    Events: {}
  Views:
    Shared: {}
    StaffPlans:
      Client: {}
      WorkWeeks: {}
      Assignments: {}
    Assignments: {}
    Users: {}
    Projects:
      WorkWeeks: {}
    Clients: {}
  Routers: {}
  initialize: (data) ->
    @users = new StaffPlan.Collections.Users data.users
    @projects = new StaffPlan.Collections.Projects data.projects
    @clients = new StaffPlan.Collections.Clients data.clients
    @assignments = new StaffPlan.Collections.Assignments data.assignments
    @currentCompany = data.currentCompany
    @currentUser = data.currentUser
    @relevantYears = _.uniq(_.flatten(StaffPlan.assignments.reduce (memo, assignment) ->
                        memo.push _.uniq(assignment.work_weeks.map (week) -> moment(week.get("beginning_of_week")).year())
                        memo
                      , []))
    year = parseInt(localStorage.getItem("yearFilter"), 10)
    if _.include(@relevantYears, year)
      StaffPlan.assignments.each (assignment) ->
        assignment.set "filteredWeeks", assignment.work_weeks.select (week) ->
          moment(week.get("beginning_of_week")).year() is year

    new StaffPlan.Routers.StaffPlan
      users: @users
      projects: @projects
      clients: @clients
      currentCompany: @currentCompany
      currentUser: @currentUser
    $ -> Backbone.history.start(pushState: true)
    
    $('a:not([data-bypass])').live 'click', (event) =>
      event.preventDefault()
      href = $(event.currentTarget).attr('href').slice(1)
      Backbone.history.navigate(href, true)
  
    
  addClientByName: (name, callback) ->
    @clients.create
      name: name
    ,
      success: callback
      
  addProjectByNameAndClient: (name, client, callback) ->
    @projects.create
      name: name
      client_id: client.get('id')
    ,
      success: callback
