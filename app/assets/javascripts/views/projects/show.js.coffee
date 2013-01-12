class StaffPlan.Views.Projects.Show extends StaffPlan.View
  className: "list tall"
  initialize: ->
    _.extend @, StaffPlan.Mixins.Events.weeks

    # FIXME: Only working version I know as of now
    if window.location.hash.length
      @startDate = moment(parseInt(window.location.hash.slice(1).split("=")[1], 10))
    else
      m = moment()
      @startDate = m.utc().startOf('day').subtract('days', m.day() - 1).subtract('weeks', 1)
    key "left, right", (event) =>
      @dateChanged if event.keyIdentifier.toLowerCase() is "left" then "previous" else "next"

    @debouncedRender = _.debounce(@render, 100)
    $(window).bind "resize", (event) =>
      @debouncedRender()

    @on "date:changed", (message) => @dateChanged(message.action)
    @on "week:updated", (message) => @projectChartView.trigger "week:updated"
    @on "year:changed", (message) => @yearChanged(parseInt(message.year, 10))
    
    
  events: ->
    "click a[data-action=add-user]": "addUserToProject"
    "click a[data-action=delete]": "deleteAssignment"

  # Delete modal used to destroy an assignment and make sure the user understands the consequences
  deleteAssignment: ->

    event.preventDefault()
    event.stopPropagation()
    user = StaffPlan.users.get($(event.target).closest('a[data-action=delete]').data('user-id'))
    assignment = user.getAassignments().detect (assignment) =>
      @model.id is assignment.get "project_id"
    deleteView = new window.StaffPlan.Views.Shared.DeleteModal
      model: assignment
      collection: user.getAssignments()
      parentView: @

    @appendChild deleteView

    $('#delete_modal').modal
      show: true
      keyboard: true
      backdrop: 'static'


  addUserToProject: (event) ->
    event.preventDefault()
    event.stopPropagation()
    targetUser = StaffPlan.users.get(@$el.find("select.unassigned-users").val())
    unless targetUser?
      StaffPlan.assignments.create
        project_id: @model.id
        proposed: false
      , success: (model, response) =>
          model.set "client_id", @model.get("client_id")
          @render()
      , error: (model, xhr, options) ->
          
    else
      StaffPlan.assignments.create
        project_id: @model.id
        user_id: targetUser.id
        proposed: false
      , success: (model, response) =>
          model.set "client_id", @model.get("client_id")
          @render()
      , error: (model, xhr, options) ->
          alert "SOMETHING WENT WRONG"
    

  render: ->
    super

    # HEADER
    @$el.find('header').append StaffPlan.Templates.Projects.show.header
      name: @model.get "name"
    
    # Each line is a list-item with 25 pixels of left margin
    # Each line has a 180 pixels-wide user information component and a 60px-wide 
    # totals component.
    # Since we have actuals and estimates, we also have a 
    # 35 pixels-wide labels div before the inputs
    # Adding 40ox of "buffer space" to the tally for security
    @numberOfBars = Math.floor ( ($('body').width() - 360) / 40 )

    @projectChartView = new StaffPlan.Views.WeeklyAggregates
      begin: @startDate.valueOf()
      count: @numberOfBars
      model: @model
      parent: @
      el: @$el.find("svg.user-chart")
      height: 120
      
    @renderChildInto @projectChartView, @$el.find "div.chart-container"
    
    if StaffPlan.relevantYears.length > 2
      @yearFilter = new StaffPlan.Views.Shared.YearFilter
        years: StaffPlan.relevantYears.sort()
        parent: @
      @$el.find('header .inner ul:first').append @yearFilter.render().el

    # THE USERS AND THEIR INPUTS
    @model.getAssignments().each (assignment) =>
      view = new StaffPlan.Views.Assignments.ListItem
        model: assignment
        parent: @
        start: @startDate
        numberOfBars: @numberOfBars
      @appendChildTo view, @$el.find('section.main')

    # DATE PAGINATOR
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
      parent: @
    @renderChildInto dateRangeView, @$el.find "#date-target"

    # If there are users not assigned to this project in the current company, show them here
    unassignedUsers = @model.getUnassignedUsers()
    @$el.find('section.main').append StaffPlan.Templates.Projects.show.addSomeone
      unassignedUsers: unassignedUsers.map (u) -> u.attributes
      projectId: @model.id
    
    @
