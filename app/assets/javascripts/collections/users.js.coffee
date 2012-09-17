class window.StaffPlan.Collections.Users extends Backbone.Collection
  model: window.StaffPlan.Models.User
  
  url: ->
    "/users"
