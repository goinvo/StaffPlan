class ProjectView extends Backbone.View
  
  className: 'project'
  id: "project-#{@cid}"
  project_view_template: $('#project_view').remove().text()
  
  initialize: ->
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
    
    clientName: =>
      match = _.detect window._meta.clients, (client) =>
        client.id == @model.get "client_id"
        
      if match? then match.name else 'N/A'
    
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
    
  addNewProject: (event) ->
    @model.collection.add
      "client_id": $( @el ).closest( 'section' ).data().clientId
  
  removeProject: (event) ->
    @model.destroy()
    
  onKeydown: (event) ->
    if event.keyCode == 13
      event.preventDefault()
      
      attributes =
        name: $( @el ).find("input[name='project[name]']").val()
      
      if @model.isNew()
        attributes = $.extend attributes,
          client_name: $( @el ).find("input[name='client[name]']").val()
        
      @model.save attributes,
        success: (project, response) =>
          if response.status == "ok"
            @model.set response.model
            window._meta.clients = response.clients
            @render()
            @model.trigger 'save:complete'
            
            @model.projects.add {}
            
          else
            alert("Failed to save that project.")


window.ProjectView = ProjectView