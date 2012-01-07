class ProjectView extends Backbone.View
  
  tagName: 'tr'
  className: 'project'
  id: "project-#{@cid}"
  
  initialize: ->
    setTimeout =>
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
      .find( 'td.months-and-weeks' )
      .html @model.work_weeks.view.render().el
    
    @
  
  events:
    "click a.add-new-project" : "addNewProject"
    "click a.remove-project" : 'removeProject'
    "keydown input[name='project[name]']" : "onKeydown"
    
  addNewProject: (event) ->
    @model.collection.add
      "client_id": $( @el ).closest( 'tbody' ).data().clientId
  
  removeProject: (event) ->
    @model.destroy()
    
  onKeydown: (event) ->
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
              alert("Failed to save that project.")


window.ProjectView = ProjectView