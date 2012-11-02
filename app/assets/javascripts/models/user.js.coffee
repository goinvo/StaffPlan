class window.StaffPlan.Models.User extends StaffPlan.Model
  NAME: "user"
  initialize: ->
    @assignments = new StaffPlan.Collections.Assignments @get( "assignments" ),
      parent: @
    
    @membership = new StaffPlan.Models.Membership @get( "membership" ),
      parent: @
    
    @bind "remove", () ->
      @destroy()

  # Proxy so that the aggregation is generic
  getAssignments: () ->
    @assignments
  

  toJSON: ->
    first_name: @get("first_name")
    last_name: @get("last_name")
    email: @get("email")

  dateChanged: (event) ->
    event.preventDefault()
    interval = if $(event.currentTarget).data().changePage == 'next' then @weekInterval else -@weekInterval
    @fromDate.add('weeks', interval)
    @toDate.add('weeks', interval)
    @view.renderContent()
    @weekHourCounter.render @dateRangeMeta().dates, @projects.models

  dateRangeMeta: ->
    @view.dateRangeMeta()

  projectsByClient: ->
    _.reduce @projects.models, (projectsByClient, project) ->
        clientId = project.getClientId()
        projectsByClient[ clientId ] ||= []
        projectsByClient[ clientId ].push project
        projectsByClient
      , {}
