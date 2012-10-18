class window.StaffPlan.Collections.Projects extends Backbone.Collection
  model: StaffPlan.Models.Project
    
  url: ->
    "/projects"
