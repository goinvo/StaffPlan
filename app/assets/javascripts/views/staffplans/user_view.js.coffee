class views.staffplans.UserView extends Support.CompositeView

  tagName: "div"
  className: "staffplan"
    
  events:
    "click a[data-change-page]" : "changePage"

  changePage: (event) ->
    @model.dateChanged event

    @$( '.headers .months-and-weeks' )
      .html( Mustache.to_html( @templates.work_week_header, @headerTemplateData() ) )

  fromDate: ->
    new Date

  initialize: ->
    @model.view = @
    
    @model.projects.bind 'add', (project) =>
      projects = @model.projectsByClient()
      clientId = project.getClientId()
      @renderProjectsForClient clientId, projects[ clientId ]

      setTimeout -> $(project.view.el).find('input[name="project[name]"]').focus()
    
    @model.projects.bind 'project:created', (project) =>
      projects = @model.projectsByClient()
      @renderProjectsForClient project.get("client_id"), projects[ project.get("client_id") ]
      
      setTimeout => @addNewProjectRow()
    
    @render()
    @renderAllProjects()

  templateData: ->
    name: @model.get("name")
    fromDate: @model.fromDate
    gravatar: @model.get("gravatar")
    id: @model.get("id")

  headerTemplateData: ->
    meta = @model.dateRangeMeta()

    monthNames: ->
      _.map meta.dates, (dateMeta, idx, dateMetas) ->
        name: if dateMetas[idx - 1] == undefined or dateMeta.month != dateMetas[idx - 1].month then _meta.abbr_months[ dateMeta.month - 1 ] else ""

    weeks: ->
      _.map meta.dates, (dateMeta, idx, dateMetas) ->
        name: "W#{Math.ceil dateMeta.mday / 7}"

  render: ->
    $( @el )
      .attr(
        id: "staffplan_#{@model.id || @model.cid}"
      )
      .html( Mustache.to_html( @templates.user, @templateData(), @partials ) )
      .find( '.months-and-weeks' )
      .html( Mustache.to_html( @templates.work_week_header, @headerTemplateData() ) )

    $( @el )
      .find( '.week-hour-counter' )
      .append( Array(@model.weekInterval + 1).join('<li></li>') )

    $( @el )
      .appendTo '.content'

    setTimeout => @addNewProjectRow()

    @
  
  partials:
    user_info: """
    <div class='user-info'>
      <a href='/users/{{ id }}'>
        <img class='gravatar' src='{{ gravatar }}' />
        <span class='name'>{{ name }}</span>
        <span class='email'>{{ email }}</span>
      </a>
    </div>
    """
    
  templates:
    user: """
    <div class='user-select'>
      {{> user_info }}
      <div class='date-pagination'>
        <a href='#' data-change-page='previous' class='previous'>&larr;</a>
        <ul class='week-hour-counter'></ul>
        <a href='#' data-change-page='next' class='next'>&rarr;</a>
      </div>
    </div>
    <div class='project-list'>
      <section class='headers'>
        <div class='client-name'>Client</div>
        <div class='new-project'>&nbsp;</div>
        <div class='project-name'>Project</div>
        <div class='months-and-weeks'></div>
      </section>
    </div>
    """
    
    work_week_header: """
    <section>
      <div class='plan-actual'>
        <div class='row-label'>&nbsp;</div>
        {{#monthNames}}
        <div>{{ name }}</div>
        {{/monthNames}}
        <div class='total'></div>
        <div class='diff-remove-project'></div>
      </div>
      <div class='plan-actual'>
        <div class='row-label'>&nbsp;</div>
        {{#weeks}}
        <div>{{ name }}</div>
        {{/weeks}}
        <div class='total'>Total</div>
        <div class='diff-remove-project'></div>
      </div>
    </section>
    """
    

  renderAllProjects: ->
    for clientId, projects of @model.projectsByClient()
      @renderProjectsForClient clientId, projects

    @renderWeekHourCounter()

  renderProjectsForClient: (clientId, projects) ->
    section = $( "<section data-client-id='#{clientId}'>" ).append(
      projects.map (project) ->
        unless project.view?
          project.view = new views.staffplans.ProjectView
            model: project
            user: @model
        
        project.view.render().el
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

    # Total hours for each week
    _.each ww, (hours, key) ->
      ww[key] = _.reduce hours, (m, o) ->
        m.actual += (parseInt(o.get('actual_hours'), 10) or 0)
        m.estimated += (parseInt(o.get('estimated_hours'), 10) or 0)
        m
      , {actual: 0, estimated: 0}

    # Scale
    whc = @$ '.user-select'
    max = Math.max.apply( null, _.pluck( ww, 'actual' ).concat( _.pluck( ww, 'estimated' ) ) ) || 1
    ratio = ( whc.height() - 20 ) / max

    # Draw
    weekHourCounters = whc.find '.week-hour-counter li'
    _.each dateRange, (date, idx) ->
      # Map week to <li>
      noActualsForWeek = false
      li = weekHourCounters.eq(idx)
      workWeek = ww["#{date.year}-#{date.mweek}"]
      total = if workWeek? then workWeek[if date.weekHasPassed then 'actual' else 'estimated'] else 0
      if total == 0 && date.weekHasPassed
        noActualsForWeek = true
        total = (if workWeek? then workWeek['estimated'] else 0)  || 0
        
      li
        .height(total * ratio)
        .html("<span>" + total + "</span>")
        .removeClass "present"

      if isThisWeek(date)
        if noActualsForWeek then li.addClass "present" else li.addClass "passed"
      else if date.weekHasPassed
        li.addClass "passed"
      else
        li.removeClass "passed"

  addNewProjectRow: ->
    undefinedClientId = @$('section[data-client-id="new_client"]')
    if undefinedClientId.length == 0 || undefinedClientId.is(":empty")
      undefinedClientId.remove()
      @model.projects.add {}

views.staffplans.UserView= views.staffplans.UserView
