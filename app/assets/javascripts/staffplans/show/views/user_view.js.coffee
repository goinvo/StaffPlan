class UserView extends Backbone.View
  
  tagName: "div"
  className: "staffplan"
  
  fromDate: ->
    Date.today()
    
  table: ->
    $( @el ).find '> table'
  
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
      .html( ich.user_view( @templateData() ) )
      .find( 'th.months-and-weeks' )
      .html( ich.work_week_header( @headerTemplateData() ) )
    
    $( @el )
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