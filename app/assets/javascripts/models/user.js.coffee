class User extends Backbone.Model
  initialize: (userdata) ->
    @projects = new ProjectList @get( "projects" ),
      parent: @
    
    @work_weeks = new WorkWeekList @get( "work_weeks" ),
      parent: @
    
    $( document.body ).bind 'work_week:value:updated', =>
      @view.renderWeekHourCounter()

    urlRoot: "/users"
    
  dateRangeMeta: ->
    @view.dateRangeMeta()

  projectsByClient: ->
    _.reduce @projects.models, (projectsByClient, project) ->
        clientId = project.getClientId()
        projectsByClient[ clientId ] ||= []
        projectsByClient[ clientId ].push project
        projectsByClient
      , {}

class UserList extends Backbone.Collection
  model: User
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
    
  url: ->
    @parent.url() + "/users"

window.User = User
window.UserList = UserList