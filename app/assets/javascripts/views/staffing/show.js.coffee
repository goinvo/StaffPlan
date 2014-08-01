class window.StaffPlan.Views.Staffing.Show extends StaffPlan.View
  attributes:
    id: "staffing-show"
    class: "extra-short"
  
  events:
    "click [data-toggle='popover']": 'showPopover'
    
  showPopover: (event) ->
    $('.popover:visible').fadeOut 'fast'
    @$el.find(event.target).popover().popover('show')
    
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
    activeUsers = _.sortBy(StaffPlan.users.active(), (user) -> user.get('first_name'))
    activeUserIds = _.pluck(activeUsers, "id")
    usersSection = @$el.find('#user-list')
    
    assignmentsForDateRange = StaffPlan.assignments.filter (assignment) ->
      activeUserIds.indexOf(assignment.get('user_id')) >= 0 &&
        # TODO: optimize this by filtering out work weeks not in the range once. This is duplicated in @renderClients
        _.any(assignment.work_weeks.models, (work_week) ->
          dateRange.indexOf(work_week.get('beginning_of_week')) >= 0 &&
            (work_week.get('estimated_hours') || 0) > 0
        )
        
    unless _.isEmpty assignmentsForDateRange
      usersSection.html("<div class='header clients'><h5>Users</h5></div>")
      
    assignmentsByUserId = _.groupBy assignmentsForDateRange, (assignment) -> assignment.get('user_id')
      
    _.each activeUsers, (user) ->
      userAssignments = assignmentsByUserId[user.id]
      
      usersSection.append HandlebarsTemplates["staffing/user"]
        first_name: user.get('first_name')
        last_name: user.get('last_name')
        user_id: user.id
        weekly_totals: _.reduce(dateRange, (totalArray, beginningOfWeek) ->
          relevantWorkWeeks = _.map this, (assignment) ->
            assignment.work_weeks.where
              beginning_of_week: beginningOfWeek
            
          relevantWorkWeeks = _.flatten relevantWorkWeeks
          
          if _.isEmpty(relevantWorkWeeks)
            weeklyTotal =
              total_hours: 0
          else
            weeklyTotal =
              total_hours: _.reduce(relevantWorkWeeks, (sum, workWeek) ->
                sum += workWeek.get('estimated_hours') || 0
              , 0) / 40.0
          
          totalArray.push weeklyTotal
          totalArray
        , [], userAssignments)
        
  renderClients: ->
    dateRange = _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    clientsSection = @$el.find('#client-list')
    activeClients = _.sortBy StaffPlan.clients.active(), (client) -> client.get('name')
    activeClientIds = _.pluck activeClients, "id"
    
    assignmentsForDateRange = StaffPlan.assignments.filter (assignment) ->
      activeClientIds.indexOf(assignment.get('client_id')) >= 0 &&
        # TODO: optimize this by filtering out work weeks not in the range once. This is duplicated in @renderUsers
        _.any(assignment.work_weeks.models, (work_week) ->
          dateRange.indexOf(work_week.get('beginning_of_week')) >= 0 &&
            (work_week.get('estimated_hours') || 0) > 0
        )
        
    unless _.isEmpty assignmentsForDateRange
      clientsSection.html("<div class='header clients'><h5>Clients</h5></div>")
    
    assignmentsByClientId = _.groupBy assignmentsForDateRange, (assignment) ->
      assignment.get('client_id')
    
    activeClientsWithProjects = _.select activeClients, (client) -> _.keys(assignmentsByClientId).indexOf(client.id.toString()) >= 0
    
    _.each activeClientsWithProjects, (client) ->
      clientAssignments = assignmentsByClientId[client.id]
      
      clientsSection.append HandlebarsTemplates["staffing/client"]
        name: client.get('name')
        client_id: client.id
        weekly_totals: _.reduce(dateRange, (totalArray, beginningOfWeek) ->
          relevantWorkWeeks = _.map this, (assignment) ->
            assignment.work_weeks.where
              beginning_of_week: beginningOfWeek
          
          relevantWorkWeeks = _.flatten relevantWorkWeeks
          
          if _.isEmpty(relevantWorkWeeks)
            weeklyTotal =
              total_hours: 0
          else
            weeklyTotal =
              total_hours: _.reduce(relevantWorkWeeks, (sum, workWeek) ->
                  sum += workWeek.get('estimated_hours') || 0
              , 0) / 40.0
          
          totalArray.push weeklyTotal
          totalArray
        , [], clientAssignments)
    
  render: ->
    super
    
    @calculateNumberOfBars()
    
    @$el.find('section.main').append HandlebarsTemplates["staffing/show"]()
    
    @renderDatesAndPagination()
    
    @renderUsers()
    
    @renderClients()
    
    @
