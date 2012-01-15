class UserView extends Backbone.View
  
  tagName: "div"
  className: "staffplan"
  
  user_view_template: $('#user_view').remove().text()
  work_week_header_template: $('#work_week_header').remove().text()
  
  fromDate: ->
    Date.today()
  
  initialize: ->  
    @render()
    
    for clientId, projects of @model.projectsByClient()
      @renderProjectsForClient clientId, projects
    
  templateData: ->
    name: @model.get("name")
    fromDate: @model.fromDate()
  
  headerTemplateData: ->
    meta = @model.dateRangeMeta()
    
    monthNames: ->
      _.map(meta.dates, (dateMeta, idx, dateMetas) ->
        name: if dateMetas[idx - 1] == undefined or dateMeta.month != dateMetas[idx - 1].month then _meta.abbr_months[ dateMeta.month ] else ""
      )
    
    weeks: ->
      _.map(meta.dates, (dateMeta, idx, dateMetas) ->
        name: "W#{dateMeta.mweek}"
      )
      
  render: ->
    $( @el )
      .html( Mustache.to_html( @user_view_template, @templateData() ) )
      .find( '.months-and-weeks' )
      .html( Mustache.to_html( @work_week_header_template, @headerTemplateData() ) )
    
    $( @el )
      .appendTo '.content'
    
    @addNewProjectRow()
    
    @
  
  renderProjectsForClient: (clientId, projects) ->
    section = $( "<section data-client-id='#{clientId}'>" ).append(
      projects.map (project, index, projects) -> project.view.el
    )
      
    existingTbody = $( @el ).find "section[data-client-id='#{clientId}']"
    
    if existingTbody.length
      $( @el )
        .find("section[data-client-id='#{clientId}']")
        .replaceWith( section )
    else
      @$('.project-list').append section
  
  addNewProjectRow: ->
    unless @$('section[data-client-id="undefined"]').length
      @model.projects.add {}
      
window.UserView = UserView