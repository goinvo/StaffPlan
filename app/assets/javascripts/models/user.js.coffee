class window.StaffPlan.Models.User extends Backbone.Model
  initialize: (userdata) ->
    # @projects = new ProjectList @get( "projects" ),
    #   parent: @
    # 
    # @work_weeks = new WorkWeekList @get( "work_weeks" ),
    #   parent: @
    # 
    # # Week Hour Counter (initialised and set in UserView)
    # $( document.body ).bind 'work_week:value:updated', =>
    #   if @view?.weekHourCounter?
    #     @view.weekHourCounter.render @dateRangeMeta().dates, @projects.models
  
  url: ->
    "#{@collection.url()}/#{@id}"

  dateChanged: (event) ->
    event.preventDefault()
    interval = if $(event.currentTarget).data().changePage == 'next' then @weekInterval else -@weekInterval
    @fromDate.add('weeks', interval)
    @toDate.add('weeks', interval)
    @view.renderContent()
    @weekHourCounter.render @dateRangeMeta().dates, @projects.models

  dateRangeMeta: ->
    @view.dateRangeMeta()

  getYearsAndWeeks: ->
    # FIXME: This is a rehash from the code in app/assets/javascript/views/_shared/date_driven_view.js.coffee 
    yearsAndWeeks = []
    from = @fromDate.clone()
    to = @toDate.clone()

    while from < to
      yearsAndWeeks.push
        year:  from.year()
        cweek: +from.format('w') # moment is nice but unfortunately doesn't yet provide an .isoWeek function
        month: from.month() + 1
        mweek: +from.format('w') # moment is nice but unfortunately doesn't yet provide an .isoWeek function
        mday:  from.date()
        weekHasPassed: from < moment()

      from.add('weeks', 1)
    yearsAndWeeks

  projectsByClient: ->
    _.reduce @projects.models, (projectsByClient, project) ->
        clientId = project.getClientId()
        projectsByClient[ clientId ] ||= []
        projectsByClient[ clientId ].push project
        projectsByClient
      , {}