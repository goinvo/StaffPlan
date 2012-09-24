class views.staffplans.UserView extends views.shared.DateDrivenView

  tagName: "div"
  className: "staffplan"
    
  events:
    "click a[data-change-page]" : "changePage"

  changePage: (event) ->
    @dateChanged event
    @renderContent()
    @$( '.headers .months-and-weeks' )
      .html( Mustache.to_html( @templates.work_week_header, @headerTemplateData() ) )
    
    @$('section.headers div.months-and-weeks div.plan-actual:first .row-label').html @fromDate.year()
    
  initialize: ->
    views.shared.DateDrivenView.prototype.initialize.call(this)
    
    @container_selector = '.project-list > section[data-client-id]:first .months-and-weeks'
    
    @model.view = @
    @model.url = ->
      "/users/#{@id}"
    
    @model.projects.bind 'add', (project) =>
      projects = @model.projectsByClient()
      clientId = project.getClientId()
      @renderProjectsForClient clientId, projects[ clientId ]

      setTimeout -> $(project.view.el).find('input[name="project[name]"]').focus()
    
    @model.projects.bind 'project:created', (project) =>
      projects = @model.projectsByClient()
      @renderProjectsForClient project.get("client_id"), projects[ project.get("client_id") ]
      
      setTimeout => @addNewProjectRow()
    
    @bind 'date:changed', =>
      @weekHourCounter.render @dateRangeMeta().dates, @model.projects.models
    
    @render()
    @renderContent()

  templateData: ->
    name: @model.get("full_name")
    fromDate: @fromDate
    gravatar: @model.get("gravatar")
    id: @model.get("id")

  headerTemplateData: ->
    meta = @dateRangeMeta()
    currentYear: ->
      moment().year()
    monthNames: ->
      # meta.dates is an array of date objects, as created in getYearsAndWeeks
      _.map meta.dates, (dateMeta, idx, dateMetas) ->
        name: if dateMetas[idx - 1] == undefined or dateMeta.month != dateMetas[idx - 1].month then moment.monthsShort[ dateMeta.month - 1 ] else ""

    weeks: ->
      _.map meta.dates, (dateMeta, idx, dateMetas) ->
        name: "W#{Math.ceil dateMeta.mday / 7}"
  
  renderWeekHourCounter: ->
    @weekHourCounter = new views.shared.ChartTotalsView @dateRangeMeta().dates, @model.projects.models, ".user-select", @$ ".week-hour-counter"
    
  renderHeaderTemplate: (append=false) ->
    html = Mustache.to_html( @templates.work_week_header, @headerTemplateData() )
    if append
      @$el.find( '.months-and-weeks' ).html( html )
    else
      html
  
  render: ->
    $( @el )
      .attr(
        id: "staffplan_#{@model.id || @model.cid}"
      )
      .html( Mustache.to_html( @templates.user, @templateData(), @partials ) )
      .find( '.months-and-weeks' )
      .html( @renderHeaderTemplate() )

    $( @el )
      .appendTo '.content'

    @renderWeekHourCounter()

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
        <div class='row-label'>{{ currentYear }}</div>
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
    
  renderContent: =>
    for clientId, projects of @model.projectsByClient()
      @renderProjectsForClient clientId, projects

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
  

  addNewProjectRow: ->
    undefinedClientId = @$('section[data-client-id="new_client"]')
    if undefinedClientId.length == 0 || undefinedClientId.is(":empty")
      undefinedClientId.remove()
      @model.projects.add {}

views.staffplans.UserView = views.staffplans.UserView
