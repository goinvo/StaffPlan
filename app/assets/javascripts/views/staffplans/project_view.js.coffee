class views.staffplans.ProjectView extends Backbone.View
  
  className: 'project'
  id: "project-#{@cid}"
  
  initialize: ->
    
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
      .html( Mustache.to_html( @templates.project, @templateData() ) )
      .find( '.months-and-weeks' )
      .html @model.work_weeks.view.render().el
    @
  
  templates:
    project: """
    <div class='client-name'>
      {{#clientNameInput}}
      <div class='ui-widget'>
        <input class='client-select' type='text' name='client[name]' />
      </div>
      {{/clientNameInput}}
      {{^clientNameInput}}
      <a href='/clients/{{ clientId }}'>{{clientName}}</a>
      <input class='client-select' type='hidden' name='client[name]' value='{{ clientName }}'/>
      {{/clientNameInput}}
    </div>
    <div class='new-project'>
      <a class='add-new-project button-minimal'>+</a>
    </div>
    <div class='project-name'>
      {{#isNew}}
      <input type='text' name='project[name]' />
      {{/isNew}}
      {{^isNew}}
      <a href='/projects/{{ projectId }}'>{{ name }}</a>
      <input type='hidden' name='project[name]' />
      {{/isNew}}
    </div>
    <div class='months-and-weeks'></div>
    """
  
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
      @model.set { client_name: clientName, client_id: client?.get('id') }
        silent: true
      
    @model.save {},
      wait: true
      success: (project, response) =>
        if response.status == "ok"
          @model.set response.attributes
          window._meta.clients.reset response.clients.map (client) -> JSON.parse(client)
          @model.trigger 'project:created', @model
          
        else
          alert("Failed to save that project.")
  
  initClientAutocomplete: (event) ->
    $currentTarget = $( event.currentTarget )
    $currentTarget.autocomplete.destroy() if $currentTarget.autocomplete?.destroy?
    
    $( event.currentTarget ).autocomplete
      source: _.uniq( window._meta.clients.pluck 'name' )
    
  initProjectAutocomplete: (event) ->
    $currentTarget = $( event.currentTarget )
    $currentTarget.autocomplete.destroy() if $currentTarget.autocomplete?.destroy?
    
    # TODO: optimize this a bit?
    client = if @model.get('client_id')?
      window._meta.clients.get( @model.get('client_id') )
    else
      clientName = this.$('input[name="client[name]"]').val()
      window._meta.clients.detect (_client) ->
        _client.get('name') == clientName
    
    clientProjectNames = if client? then _.pluck client.get('projects'), 'name' else []
    
    currentClientProjects = @model.collection.parent.projects.select((project) ->
      project.get('client_id') == @
    , client?.id)
    
    currentClientProjectNames = currentClientProjects.map (project) ->
      project.get('name')
    
    projectNames = _.reject clientProjectNames, (projectName) ->
      currentClientProjectNames.indexOf( projectName ) >= 0
    
    $( event.currentTarget ).autocomplete
      source: projectNames
    
window.views.staffplans.ProjectView = views.staffplans.ProjectView