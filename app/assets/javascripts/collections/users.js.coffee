class window.StaffPlan.Collections.Users extends Backbone.Collection
  model: window.StaffPlan.Models.User
  NAME: "users"
  
  url: ->
    "/users"
