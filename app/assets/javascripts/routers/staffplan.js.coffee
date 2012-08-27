class StaffPlan.Routers.StaffPlan extends Support.SwappingRouter
  routes:
    "staffplans/:id": "staffplanShow"
    
  initialize: (data) ->
    @user = data.user
    @projects = data.projects
    @clients = data.clients
    
    window.router = @
  
  staffplanShow: ->
    @staffplan = new window.StaffPlan.Views.StaffPlans.Show(router: @, user: @user)