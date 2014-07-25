class StaffPlan.Routers.StaffPlan extends Support.SwappingRouter
  routes:
    "staffplans/:id"    : "staffplanShow"
    "staffplans"        : "staffplanIndex"
    "clients"           : "clientIndex"
    "clients/new"       : "clientNew"
    "clients/:id"       : "clientShow"
    "clients/:id/edit"  : "clientEdit"
    "users/new"         : "userNew"
    "users/:id"         : "userShow"
    "users/:id/edit"    : "userEdit"
    "users"             : "userIndex"
    "projects"          : "projectIndex"
    "projects/new"      : "projectNew"
    "projects/:id"      : "projectShow"
    "projects/:id/edit" : "projectEdit"
    "planning"          : "planningShow"
    
    
  initialize: (data) ->
    @users = data.users
    @projects = data.projects
    @clients = data.clients
    @currentCompany = data.currentCompany
    @currentUser = data.currentUser
    @el = $('body')
    window.router = @
  
  # Staff Plans
  staffplanShow: (userId) ->
    user = @users.get userId
    alert 'no user with that ID found' unless user?
    staffplanShow = new window.StaffPlan.Views.StaffPlans.Show
      router: @
      user: user
    @swap staffplanShow
    
  staffplanIndex: ->
    staffplanIndex = new window.StaffPlan.Views.StaffPlans.Index
      router: @
      users: @users
    @swap staffplanIndex

  # Clients
  clientIndex: ->
    clientIndex = new window.StaffPlan.Views.Clients.Index
      router: @
      collection: @clients
      currentCompany: @currentCompany
    @swap clientIndex

  clientShow: (clientId) ->
    client = @clients.get clientId
    clientShow = new window.StaffPlan.Views.Clients.Show
      router: @
      model: client
    @swap clientShow

  clientNew: ->
    client = new window.StaffPlan.Models.Client
    clientNew = new window.StaffPlan.Views.Clients.New
      router: @
      model: client
      collection: window.StaffPlan.clients

    @swap clientNew
  
  clientEdit: (clientId) ->
    client = @clients.get clientId
    clientEdit = new window.StaffPlan.Views.Clients.New
      collection: window.StaffPlan.clients,
      router: @,
      model: client,
    @swap clientEdit

  # Users
  userShow: (userId) ->
    user = @users.get userId
    userShow = new window.StaffPlan.Views.Users.Show
      router: @
      model: user
    @swap userShow

  userNew: ->
    userNew = new window.StaffPlan.Views.Users.New
      router: @
      collection: window.StaffPlan.users
    @swap userNew
 
  userIndex: ->
    userIndex = new window.StaffPlan.Views.Users.Index
      router: @
      collection: window.StaffPlan.users
      currentCompany: window.StaffPlan.currentCompany
    @swap userIndex
 
  userEdit: (userId) ->
    user = window.StaffPlan.users.get userId
    userEdit = new window.StaffPlan.Views.Users.Edit
      router: @
      model: user
    @swap userEdit

  projectNew: ->
    projectNew = new window.StaffPlan.Views.Projects.New
      router: @
      clients: window.StaffPlan.clients
      collection: window.StaffPlan.projects
      currentUser: window.StaffPlan.users.get(@currentUser.get("id"))
    @swap projectNew
  
  projectEdit: (projectId) ->
    project = window.StaffPlan.projects.get projectId
    projectEdit = new window.StaffPlan.Views.Projects.Edit
      router: @
      clients: window.StaffPlan.clients
      currentUser: window.StaffPlan.users.get(@currentUser.get('id'))
      model: project
      collection: window.StaffPlan.projects
    @swap projectEdit
  
  projectShow: (projectId) ->
    project = window.StaffPlan.projects.get projectId
    projectShow = new window.StaffPlan.Views.Projects.Show
      model: project
      router: @
    @swap projectShow

  projectIndex: ->
    projectIndex = new window.StaffPlan.Views.Projects.Index
      router: @
      collection: window.StaffPlan.projects
    @swap projectIndex
  
  planningShow: ->
    planningShow = new window.StaffPlan.Views.Planning.Show
      router: @
    @swap planningShow
