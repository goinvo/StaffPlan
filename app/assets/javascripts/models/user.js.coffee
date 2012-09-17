class window.StaffPlan.Models.User extends Backbone.Model
  initialize: ->
    @assignments = new window.StaffPlan.Collections.Assignments @get( "assignments" ),
      parent: @
    
    @membership = new window.StaffPlan.Models.Membership @get( "membership" ),
      parent: @

  toJSON: ->
    userAttributes =
      first_name: @get("first_name")
      last_name: @get("last_name")
      email: @get("email")
    membershipAttributes = membership: _.clone(@membership.attributes)
    user: _.extend userAttributes, membershipAttributes

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
