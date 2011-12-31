class User extends Backbone.Model
  initialize: (userdata) ->
    
    @projects = new ProjectList @get( "projects" ),
      parent: @
    
    @view = new UserView
      model: @
      id: "staffplan_#{@id || @cid}"
    
    @projects.bind 'add', (project) =>
      projects = @projectsByClient()
      @view.renderProjectsForClient project.get("client_id"), projects[ project.get("client_id") ]
    
    urlRoot: "/users"
  
  projectsByClient: ->
    _.reduce @projects.models, (projectsByClient, project) ->
        projectsByClient[ project.get( 'client_id' ) ] ||= []
        projectsByClient[ project.get( 'client_id' ) ].push project
        projectsByClient
      , {}
    
  url: ->
    "/users/#{@id}"
  
window.User = User