class window.StaffPlan.Collections.Users extends Backbone.Collection
  NAME: "users"
  model: StaffPlan.Models.User
  
  url: ->
    "/users"

  active: ->
    @select (user) ->
      not (user.membership.get("archived") or user.membership.get("disabled"))
  inactive: ->
    @select (user) ->
      user.membership.get("archived") or user.membership.get("disabled")
