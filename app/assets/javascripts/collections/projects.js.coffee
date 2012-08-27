class window.StaffPlan.Collections.Projects extends Backbone.Collection
  model: window.StaffPlan.Models.Project
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
    
  url: ->
    @parent.url() + "/projects"