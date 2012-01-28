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
      .find( '.week-hour-counter' )
      .append( Array(@model.weekInterval + 1).join('<li></li>') )

    $( @el )
      .appendTo '.content'

    @addNewProjectRow()

    @

  renderAllProjects: ->
    for clientId, projects of @model.projectsByClient()
      @renderProjectsForClient clientId, projects

    @renderWeekHourCounter()

  renderProjectsForClient: (clientId, projects) ->
    section = $( "<section data-client-id='#{clientId}'>" ).append(
      projects.map (project) -> project.view.render().el
    )

    existingTbody = $( @el ).find "section[data-client-id='#{clientId}']"

    if existingTbody.length
      $( @el )
        .find("section[data-client-id='#{clientId}']")
        .replaceWith( section )
    else
      @$('.project-list').append section


  renderWeekHourCounter: ->
    # Gompute
    dateRange = @model.dateRangeMeta().dates
    ww = _.map @model.projects.models, (p) ->
      _.map dateRange, (date) ->
        p.work_weeks.find (m) ->
          m.get('cweek') == date.mweek and m.get('year') == date.year

    # Format data
    ww = _.groupBy _.compact(_.flatten(ww)), (w) ->
      "#{w.get('year')}-#{w.get('cweek')}"

    # Draw
    weekHourCounters = @$( '.week-hour-counter li' )
    _.each dateRange, (date, idx) ->
      # Map week to <li>
      li = weekHourCounters.eq(idx)
      total = _.reduce ww["#{date.year}-#{date.mweek}"], (m, o) ->
        m + parseInt(o.get(if date.weekHasPassed then 'actual_hours' else 'estimated_hours'), 10) or 0
      , 0
      li
        .height(total)
        .html("<span>" + total + "</span>")
      if date.weekHasPassed
        li.addClass("passed")
      else
        li.removeClass("passed")

  addNewProjectRow: ->
    undefinedClientId = @$('section[data-client-id="undefined"]')
    if undefinedClientId.length == 0 || undefinedClientId.is(":empty")
      undefinedClientId.remove()
      @model.projects.add {}

window.UserView = UserView
