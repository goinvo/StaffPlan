class window.StaffPlan.Collections.Users extends Backbone.Collection
  model: StaffPlan.Models.User
  
  url: ->
    "/users"
