class Project extends Backbone.Model
  initialize: ->
    
    @work_weeks = new WorkWeekList @get('work_weeks'),
      parent: @
      
    @view = new ProjectView
      model: @
      id: "project_#{@id}"
      
    @bind 'destroy', (event) ->
      @collection.remove @
      @view.remove()
    
    @bind 'change:id', (event) ->
      @view.render()
      
      setTimeout =>
        @work_weeks.view.delegateEvents()
    
    @bind 'save', (event) -> @view.render()
  
  validate: (attributes) ->
    if @get('name') == ''
      # alert("")
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