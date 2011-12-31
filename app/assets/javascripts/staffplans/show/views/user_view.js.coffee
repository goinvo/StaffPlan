class UserView extends Backbone.View
  
  tagName: "div"
  className: "staffplan"
  
  table: ->
    $( @el ).find '> table'
  
  initialize: ->
    @render()
    
    for clientId, projects of @model.projectsByClient()
      @renderProjectsForClient clientId, projects
    
  templateData: ->
    name: @model.get("name")
    
  render: ->
    $( @el )
      .html( ich.user_view( @templateData() ) )
      .appendTo '.content'
    
    @
  
  renderProjectsForClient: (clientId, projects) ->
    tbody = $( "<tbody data-client-id='#{clientId}'>" ).append projects.map (project, index, projects) -> project.view.el
    existingTbody = $( @el ).find "tbody[data-client-id='#{clientId}']"
    
    if existingTbody.length
      $( @el )
        .find("tbody[data-client-id='#{clientId}']")
        .replaceWith( tbody )
    else
      @table().append tbody
      
window.UserView = UserView