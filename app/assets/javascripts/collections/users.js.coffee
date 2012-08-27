class window.StaffPlan.Collections.Users extends Backbone.Collection
  model: window.StaffPlan.Models.User
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
    
  url: ->
    @parent.url() + "/users"