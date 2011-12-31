class Project extends Backbone.Model
  initialize: ->
    
    @view = new ProjectView
      model: @
      id: "project_#{@id}"
    
  urlRoot: "/views"
  
class ProjectList extends Backbone.Collection
  model: Project
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
  
  url: ->
    @parent.url() + "/projects"

window.Project = Project
window.ProjectList = ProjectList