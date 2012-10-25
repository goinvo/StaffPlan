class window.StaffPlan.Views.StaffPlans.Show extends window.StaffPlan.Views.Shared.DateDrivenView
  className: "staffplan"
  tagName: "div"
  
  templates:
    frame: '''
    <div id="user-select" class="grid-row user-info padded">
      <div class="grid-row-element fixed-360">
        <img class="gravatar" src="{{user.gravatar}}" />
        <span class='name'>
          <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
        </span>
      </div>
      <div id="user-chart" class="grid-row-element flex chart-totals-view">
        <a class="previous flex" href="#" data-change-page='previous'>Previous</a>
          <ul>
          </ul>
        <a class="next flex" href="#" data-change-page='next'>Next</a>
      </div>
      <div class="grid-row-element"></div>
    </div>
    <div class='header grid-row padded'>
      <div class='grid-row-element fixed-180 title'><span>Client</span></div>
      <div class='grid-row-element fixed-180 title'><span>Project</span></div>
      <div class="grid-row-element flex date-range-target" id="interval-width-target"></div>
    </div>
    '''
  
    workWeeksAndYears: """
    <div class="cweeks-and-years"><div>{{{calendarYears dates}}}</div>{{{calendarMonths dates}}}</div>
    <div class="cweeks-and-years"><div></div>{{{calendarWeeks dates}}}</div>
    """
  
  gatherClientsByAssignments: ->
    _.uniq @model.assignments.pluck( 'client_id' ).map (clientId) -> StaffPlan.clients.get clientId
    
  initialize: ->
    window.StaffPlan.Views.Shared.DateDrivenView.prototype.initialize.call(this)
    
    Handlebars.registerHelper 'calendarYears', (dates) ->
      _.uniq(_.pluck dates, 'year').join("/<br/>")
      
    Handlebars.registerHelper 'calendarMonths', (dates) ->
      currentMonthName = null
      
      _.reduce dates, (html, date, index, dates) ->
        cell_content = ''
          
        unless currentMonthName?
          currentMonthName = date.xdate.toString 'MMM'
          cell_content += "<span class='month-name'>#{currentMonthName}</span>"
        else
          if date.xdate.toString('MMM') != currentMonthName
            currentMonthName = date.xdate.toString 'MMM'
            cell_content += "<span class='month-name'>#{currentMonthName}</span>"
        
        html += "<div>#{cell_content}</div>"
        html
        
      , ""
      
    
    Handlebars.registerHelper 'calendarWeeks',   (dates) ->
      _.reduce dates, (html, date, index, dates) ->
        html += "<div>W#{Math.ceil(date.mday / 7)}</div>"
        html
      , ""
    
    @$el.bind 'click', "[data-change-page]", (event) => @changePage( event )
    key 'left, right', (event) => @changePage( event )
      
    @model = @options.user
    @model.view = @
    
    # a local list of clients for whom this user is assigned projects
    @clients = new StaffPlan.Collections.Clients @gatherClientsByAssignments()
    @clients.bind 'add', (client) =>
      @clientViews.push client.view = new StaffPlan.Views.StaffPlans.Client
        model: client
        user: @model
        assignments: []
      client.view.assignments.add()
      client.view.render()
      @$el.append client.view.el
      
    
    @frameTemplate = Handlebars.compile @templates.frame
    @workWeekAndYearsTemplate = Handlebars.compile @templates.workWeeksAndYears
    @assignmentTemplate = Handlebars.compile @templates.assignment
    
    @$el.append @frameTemplate
      user: @model.attributes
    
    @$el.append @clientViews = @clients.map (client) =>
      client.view = new StaffPlan.Views.StaffPlans.Client
        model: client
        user: @model
        assignments: @model.assignments.where
          client_id: client.id
    
    
    @$el.append @clientViews.map (clientView) -> clientView.el
  
  changePage: (event) ->
    @dateChanged( event )
    @render()

  render: ->
    if @$el.closest('html').length == 0
      # first render
      @$el.appendTo('section.main')
      @setWeekIntervalAndToDate()
      @weekHourCounter = new StaffPlan.Views.Shared.ChartTotalsView @dateRangeMeta().dates, _.uniq(_.flatten(@clients.reduce((assignmentArray, client, index, clients) ->
        assignmentArray.push client.view.assignments.models
        assignmentArray
      , [], @)))
      , "#user-chart", @$ ".chart-totals-view ul"
    
      setTimeout => @addNewClientAndProjectInputs()
    
    else
      # re-render
      @weekHourCounter.render @dateRangeMeta().dates, _.uniq(_.flatten(@clients.reduce((assignmentArray, client, index, clients) ->
        assignmentArray.push client.view.assignments.models
        assignmentArray
      , [], @)))
    
    @$el.find( '.date-range-target' ).html @workWeekAndYearsTemplate
      dates: @dateRangeMeta().dates
    
    @clientViews.map (clientView) -> clientView.render()

    @weekHourCounter = new StaffPlan.Views.Shared.ChartTotalsView @dateRangeMeta().dates, _.uniq(_.flatten(@clients.reduce((assignmentArray, client, index, clients) ->
      assignmentArray.push client.view.assignments.models
      assignmentArray
    , [], @)))
    , "#user-chart", @$ ".chart-totals-view ul"
    
    @
  
  addNewClientAndProjectInputs: ->
    @clients.add()
    
  leave: ->
    @off()
    @remove()