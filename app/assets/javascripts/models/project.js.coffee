class Project extends Backbone.Model
  initialize: ->
    
    @work_weeks = new WorkWeekList @get('work_weeks'),
      parent: @
      
    @users = new UserList @get('users'),
      parent: @
    
    @bind 'destroy', (event) -> @collection.remove @
  
  url: ->
    if @collection? then @collection.url() else "/projects/#{@id}"
    
  validate: (attributes) ->
    if @get('name') == ''
      return "Project name is required"
  
  dateRangeMeta: ->
    @view.dateRangeMeta()
  
  getClientId: ->
    @get("client_id") || "new_client"
  
class ProjectList extends Backbone.Collection
  model: Project
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
    
  url: ->
    @parent.url() + "/projects"

window.Project = Project
window.ProjectList = ProjectList
