window.StaffPlan =
  Models: {}
  Collections: {}
  Views:
    Shared: {}
    StaffPlans:
      Client: {}
      WorkWeeks: {}
      Assignments: {}
    Users: {}
    Projects: {}
    Clients: {}
  Routers: {}
  
  initialize: (data) ->
    @users = new StaffPlan.Collections.Users data.users
    @projects = new StaffPlan.Collections.Projects data.projects
    @clients = new StaffPlan.Collections.Clients data.clients
    
    new window.StaffPlan.Routers.StaffPlan
      users: @users
      projects: @projects
      clients: @clients
    
    $ -> Backbone.history.start(pushState: true)
    
    $('a:not([data-bypass])').live 'click', (event) =>
      event.preventDefault()
      href = $(event.currentTarget).attr('href').slice(1)
      Backbone.history.navigate(href, true)
