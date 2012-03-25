class Project extends Backbone.Model
  initialize: ->
    
    @work_weeks = new WorkWeekList @get('work_weeks'),
      parent: @
      
    @bind 'destroy', (event) ->
      @collection.remove @
  
  validate: (attributes) ->
    if @get('name') == ''
      return "Project name is required"
  
  dateRangeMeta: ->
    @collection.dateRangeMeta()
    
  urlRoot: "/projects"
  
class ProjectList extends Backbone.Collection
  model: Project
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
  
  dateRangeMeta: ->
    @parent.dateRangeMeta()
    
  url: ->
    @parent.url() + "/projects"

window.Project = Project
window.ProjectList = ProjectList
