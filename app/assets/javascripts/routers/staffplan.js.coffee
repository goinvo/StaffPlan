class StaffPlan.Routers.StaffPlan extends Support.SwappingRouter
  routes:
    "staffplans/:id"    : "staffplanShow"
    "staffplans"        : "staffplanIndex"
    "clients/new"       : "clientNew"
    "clients/:id"       : "clientShow"
    "clients/:id/edit"  : "clientEdit"
    "clients"           : "clientIndex"
    "users/:id"         : "userShow"
    
    
  initialize: (data) ->
    @users = data.users
    @projects = data.projects
    @clients = data.clients
    @currentCompany = data.currentCompany
    window.router = @
  
  # Staff Plans
  staffplanShow: (userId) ->
    user = @users.get userId
    alert 'no user with that ID found' if user.nil?
    staffplanShow = new window.StaffPlan.Views.StaffPlans.Show(router: @, user: user)
    @swap staffplanShow
    
  staffplanIndex: ->
    staffplanIndex = new window.StaffPlan.Views.StaffPlans.Index(router: @, users: @users)
    @swap staffplanIndex

  # Clients
  clientIndex: ->
    clientIndex = new window.StaffPlan.Views.Clients.Index(router: @, collection: @clients, currentCompany: @currentCompany)
    @swap clientIndex

  clientShow: (clientId) ->
    client = @clients.get clientId
    clientShow = new window.StaffPlan.Views.Clients.Show(router: @, model: client)
    @swap clientShow

  clientNew: ->
    client = new window.StaffPlan.Models.Client
    clientNew = new window.StaffPlan.Views.Clients.New(router: @, model: client, collection: window.StaffPlan.clients)
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
    userShow = new window.StaffPlan.Views.Users.Show(router: @, model: user)
    @swap userShow
