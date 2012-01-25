class UserView extends Backbone.View

  tagName: "div"
  className: "staffplan"

  user_view_template: $('#user_view').remove().text()
  work_week_header_template: $('#work_week_header').remove().text()

  events:
    "click a[data-change-page]" : "changePage"

  changePage: (event) ->
    @model.dateChanged event

    @$( '.headers .months-and-weeks' )
      .html( Mustache.to_html( @work_week_header_template, @headerTemplateData() ) )

  fromDate: ->
    Date.today()

  initialize: ->
    @render()
    @renderAllProjects()

  templateData: ->
    name: @model.get("name")
    fromDate: @model.fromDate

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

  renderAllProjects: ->
    for clientId, projects of @model.projectsByClient()
      @renderProjectsForClient clientId, projects

  renderProjectsForClient: (clientId, projects) ->
    section = $( "<section data-client-id='#{clientId}'>" ).append(
      projects.map (project, index, projects) -> project.view.render().el
    )

    existingTbody = $( @el ).find "section[data-client-id='#{clientId}']"

    if existingTbody.length
      $( @el )
        .find("section[data-client-id='#{clientId}']")
        .replaceWith( section )
    else
      @$('.project-list').append section

  addNewProjectRow: ->
    undefinedClientId = @$('section[data-client-id="undefined"]')
    if undefinedClientId.length == 0 || undefinedClientId.is(":empty")
      undefinedClientId.remove()
      @model.projects.add {}

window.UserView = UserView
