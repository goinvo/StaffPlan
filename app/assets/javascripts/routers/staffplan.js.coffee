class StaffPlan.Routers.StaffPlan extends Support.SwappingRouter
  routes:
    "staffplans/:id"    : "staffplanShow"
    "staffplans"        : "staffplanIndex"
    
  initialize: (data) ->
    @users = data.users
    @projects = data.projects
    @clients = data.clients
    
    window.router = @
  
  staffplanShow: (userId) ->
    user = @users.get userId
    alert 'no user with that ID found' if user.nil?
    staffplanShow = new window.StaffPlan.Views.StaffPlans.Show(router: @, user: user)
    @swap staffplanShow
    
  staffplanIndex: ->
    staffplanIndex = new window.StaffPlan.Views.StaffPlans.Index(router: @, users: @users)
    @swap staffplanIndex