class window.StaffPlan.Collections.Projects extends Backbone.Collection
  NAME: "projects"
  model: StaffPlan.Models.Project
    
  url: ->
    "/projects"
