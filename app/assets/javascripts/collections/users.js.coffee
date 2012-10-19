class window.StaffPlan.Collections.Users extends Backbone.Collection
  NAME: "users"
  model: StaffPlan.Models.User
  
  url: ->
    "/users"
