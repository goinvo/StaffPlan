window.StaffPlan =
  Models: {}
  Collections: {}
  Views:
    Shared: {}
    StaffPlans: {}
    Users: {}
    Projects: {}
    Clients: {}
  Routers: {}
  initialize: (data) ->
    @user = new StaffPlan.Models.User data.user
    @projects = new StaffPlan.Collections.Projects data.projects
    @clients = new StaffPlan.Collections.Clients data.clients
    
    new window.StaffPlan.Routers.StaffPlan
      user: @user
      projects: @projects
      clients: @clients
    
    unless Backbone.history.started
      Backbone.history.start()
      Backbone.history.started = true