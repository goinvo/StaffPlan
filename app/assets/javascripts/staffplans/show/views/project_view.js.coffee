class ProjectView extends Backbone.View
  
  className: 'project'
  id: "project-#{@cid}"
  project_view_template: $('#project_view').remove().text()
  
  initialize: ->
    # this is whack.  fix this chicken/egg problem correctly.
    setTimeout =>
      @render()
    
  templateData: ->
    name: @model.get "name"
    client_id: @model.get "client_id"
    
    clientNameInput: =>
      !@model.get("client_id")? && @model.isNew()
      
    id: @model.get "id"
    
    isNew: =>
      @model.isNew()
    
    clients: -> window._meta.clients
    clientId: => @model.get "client_id"
    projectId: => @model.get "id"
    
    clientName: =>
      match = window._meta.clients.get @model.get "client_id"
      if match? then match.get 'name' else 'N/A'
    
  render: ->
    $( @el )
      .html( Mustache.to_html( @project_view_template, @templateData() ) )
      .find( '.months-and-weeks' )
      .html @model.work_weeks.view.render().el
    @
  
  events:
    "click a.add-new-project" : "addNewProject"
    "click a.remove-project" : 'removeProject'
    "keydown input[name='project[name]']" : "onKeydown"
    "focusin input[name='client[name]']" : "initClientAutocomplete"
    "focusin input[name='project[name]']" : "initProjectAutocomplete"
    
  addNewProject: (event) ->
    @model.collection.add
      "client_id": $( @el ).closest( 'section' ).data().clientId
  
  removeProject: (event) ->
    @model.destroy()
    
  onKeydown: (event) ->
    if event.keyCode == 13
      @_createProject event
    
  _createProject: (event) ->
    event.preventDefault()
    
    @model.set { name: $( @el ).find("input[name='project[name]']").val() }
      silent: true
    
    if @model.isNew()
      clientName = $( @el ).find("input[name='client[name]']").val()
      client = window._meta.clients.detect (client) -> client.get('name') == clientName
      @model.set { client_name: clientName, client_id:  client.get('id') }
        silent: true
      
    @model.save {},
      success: (project, response) =>
        if response.status == "ok"
          @model.set response.model
          window._meta.clients.reset response.clients
          @model.trigger 'project:created', @model
          
        else
          alert("Failed to save that project.")
  
  initClientAutocomplete: (event) ->
    $currentTarget = $( event.currentTarget )
    $currentTarget.autocomplete.destroy() if $currentTarget.autocomplete?.destroy?
    
    $( event.currentTarget ).autocomplete
      source: window._meta.clients.pluck 'name'
    
  initProjectAutocomplete: (event) ->
    $currentTarget = $( event.currentTarget )
    $currentTarget.autocomplete.destroy() if $currentTarget.autocomplete?.destroy?
    
    $( event.currentTarget ).autocomplete
      # source: if @model.get('client_id')? then window._meta.clients.get( @model.get('client_id') )?.get('projects').pluck 'name' else []
      source : []
    
window.ProjectView = ProjectView