class ProjectView extends Backbone.View
  
  tagName: 'tr'
  className: 'project'
  id: "project-#{@cid}"
  
  initialize: ->
    @render()
    
  templateData: ->
    name: @model.get "name"
    client_id: @model.get "client_id"
    id: @model.get "id"
    
    isNew: =>
      @model.isNew()
    
    clientName: =>
      match = _.detect window._meta.clients, (client) =>
        client.id == @model.get "client_id"
        
      if match? then match.name else 'N/A'
    
  render: ->
    $( @el )
      .html( ich.project_view( @templateData() ) )
      
    @
  
  events:
    "click a.add-new-project" : "addNewProject"
    "click a.remove-project" : 'removeProject'
    "keydown input[type='text']" : "onKeydown"
    
  addNewProject: (event) ->
    @model.collection.add
      "client_id": $( @el ).closest( 'tbody' ).data().clientId
  
  removeProject: (event) ->
    @model.collection.remove(@model)
    @model.destroy()
    @remove()
    
  onKeydown: (event) ->
    console.log event.keyCode == 13
    
    if event.keyCode == 13
      event.preventDefault()
      
      @model.save
        name: $( @el ).find("input[name='project[name]']").val(),
          success: (project, response) =>
            if response.status == "ok"
              @model.set
                id: response.model.id
                  
              @render()
              
            else
              alert('ruh roh')

window.ProjectView = ProjectView