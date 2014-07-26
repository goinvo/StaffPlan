class window.StaffPlan.Views.Planning.Show extends StaffPlan.View
  attributes:
    id: "planning-show"
    class: "extra-short"
  
  initialize: (options={}) ->
    _.extend @, StaffPlan.Mixins.Events.weeks
    
    if window.location.hash.length
      @startDate = moment(parseInt(window.location.hash.slice(1).split("=")[1], 10))
    else
      m = moment()
      @startDate = m.utc().startOf('day').subtract('days', m.day() - 1).subtract('weeks', 1)
    
    @on "date:changed", (message) => @dateChanged(message.action)
    
    @debouncedRender = _.debounce =>
      @render()
      @onWindowResized()
    , 200
    
    $(window).bind "resize", (event) => @debouncedRender()
    
  calculateNumberOfBars: ->
    # calculate usable width for inputs
    @chartContainerWidth = $(document.body).width() - 300 # padding, margin and width of all other elements besides the flex
    @numberOfBars = Math.round(@chartContainerWidth / 39) - 2
    
  renderDatesAndPagination: ->
    # dates and pagination
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
      parent: @
    @renderChildInto dateRangeView, @$el.find "#interval-width-target"
  
  renderUsers: ->
    dateRange = _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    activeUsers = _.sortBy StaffPlan.users.active(), (user) -> user.get('first_name')
    usersSection = @$el.find('#user-list')
    activeUserIds = _.pluck(activeUsers, "id")
    assignmentsForDateRange = StaffPlan.assignments.filter (assignment) ->
      activeUserIds.indexOf(assignment.get('user_id')) > 0 &&
        # TODO: optimize this by filtering out work weeks not in the range once. This is duplicated in @renderClients
        _.find(assignment.work_weeks.models, (work_week) -> dateRange.indexOf(work_week.get('beginning_of_week')) > 0)
        
    unless _.isEmpty assignmentsForDateRange
      usersSection.html("")
      
    assignmentsByUserId = _.groupBy assignmentsForDateRange, (assignment) ->
      assignment.get('user_id')
    _.each activeUsers, (user) ->
      usersSection.append HandlebarsTemplates["planning/user"]
        first_name: user.get('first_name')
        last_name: user.get('last_name')
        work_weeks: _.map dateRange, (beginningOfWeek) ->
          userAssignment = assignmentsByUserId[user.id]
          assignmentForWorkWeek = userAssignment.work_weeks.where({beginning_of_week: beginningOfWeek})
          if assignmentForWorkWeek?
            assignmentForWorkWeek
          else
            userAssignment.work_weeks.add
              beginning_of_week: beginningOfWeek
              
  renderClients: ->
    dateRange = _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    clientsSection = @$el.find('#client-list')
    activeClients = _.sortBy StaffPlan.clients.active(), (client) -> client.get('name')
    activeClientIds = _.pluck activeClients, "id"
    assignmentsForDateRange = StaffPlan.assignments.filter (assignment) ->
      activeClientIds.indexOf(assignment.get('client_id')) > 0 &&
        # TODO: optimize this by filtering out work weeks not in the range once. This is duplicated in @renderUsers
        _.find(assignment.work_weeks.models, (work_week) -> dateRange.indexOf(work_week.get('beginning_of_week')) > 0)
        
    unless _.isEmpty assignmentsForDateRange
      clientsSection.html("")
    
    assignmentsByClientId = _.groupBy assignmentsForDateRange, (assignment) ->
      assignment.get('client_id')
    _.each activeClients, (client) ->
      clientsSection.append HandlebarsTemplates["planning/client"]
        name: client.get('name')
        work_weeks: _.map dateRange, (beginningOfWeek) ->
          clientAssignments = assignmentsByClientId[client.id]
          assignmentsForWorkWeek = clientAssignments.detect((assignment) -> assignment.work_weeks.where({beginning_of_week: beginningOfWeek}))
          if assignmentsForWorkWeek?
            assignmentsForWorkWeek
          else
            user.work_weeks.add
              beginning_of_week: beginningOfWeek
    
  render: ->
    super
    
    @calculateNumberOfBars()
    
    @$el.find('section.main').append HandlebarsTemplates["planning/show"]()
    
    @renderDatesAndPagination()
    
    @renderUsers()
    
    @renderClients()
    
    @
