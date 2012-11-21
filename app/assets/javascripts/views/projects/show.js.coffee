class StaffPlan.Views.Projects.Show extends Support.CompositeView
  className: "list padding-top-240"
  templates:
    header: '''
      <div class="position-fixed date-paginator"> 
        <div class="fixed-180">
          <a href="#" class="return-false previous pagination" data-action=previous>previous</a>
          <a href="#" class="return-false next pagination" data-action=next>next</a>
        </div>
        <div id="date-target" class="flex margin-left-40">
        </div>
      </div>
      <div class="position-fixed chart-wrapper">
        <div class="fixed-180">&nbsp;</div>
        <div class="flex chart-container margin-left-40"><svg class="user-chart"></svg></div>
      </div>
    '''
    mainContent: '''
    '''
    addSomeone: '''
      <select class="unassigned-users">
        {{#unassignedUsers}}
          <option value="{{id}}">{{first_name}} {{last_name}}</option>
        {{/unassignedUsers}}
      </select>
      <a href="/assignments" class="btn btn-primary" data-action="add-user">
        <i class="icon-list icon-white"></i>
        Add user to project
      </a>
      '''
  initialize: ->

    m = moment()
    @startDate = m.utc().startOf('day').subtract('days', m.day() - 1)

    @headerTemplate = Handlebars.compile(@templates.header)
    @mainContent = Handlebars.compile(@templates.mainContent)
    @addSomeone = Handlebars.compile(@templates.addSomeone)

    @debouncedRender = _.debounce(@render, 200)
    $(window).bind "resize", (event) =>
      @debouncedRender()
    @on "date:changed", (message) =>
      if message.action is "previous"
        @startDate.subtract('weeks', @numberOfBars)
      else
        @startDate.add('weeks', @numberOfBars)
      @children.each (child) =>
        child.trigger "date:changed",
          begin: @startDate
          count: @numberOfBars
    @on "week:updated", (message) =>
      @projectChartView.trigger "week:updated"
    
  events: ->
    "click a[data-action=add-user]": "addUserToProject"
    "click a[data-action=delete]": "deleteAssignment"

  # Delete modal used to destroy an assignment and make sure the user understands the consequences
  deleteAssignment: ->

    event.preventDefault()
    event.stopPropagation()
    # TODO: Need that stupid closest because the source of the event can be the <i> tag used by
    # Bootstrap for the button icon. Might be a better way
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
    StaffPlan.assignments.create
      project_id: @model.id
      user_id: targetUser.id
      proposed: false
    , success: (model, response) =>
        console.log "SUCCESS"
    , error: (model, response) ->
        alert "SOMETHING WENT WRONG"
    @render()
  
  render: ->
    @$el.empty()

    # HEADER
    @$el.append @headerTemplate
      name: @model.get "name"
    
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    @numberOfBars = Math.round(chartContainerWidth / 40) - 2

    @projectChartView = new StaffPlan.Views.WeeklyAggregates
      begin: @startDate.valueOf()
      count: @numberOfBars
      model: @model
      parent: @
      el: @$el.find("svg.user-chart")
      height: 120
      width: chartContainerWidth
    @renderChildInto @projectChartView, @$el.find "div.chart-container"
    

    # THE USERS AND THEIR INPUTS
    @model.getAssignments().each (assignment) =>
      view = new StaffPlan.Views.Assignments.ListItem
        model: assignment
        parent: @
        start: @startDate
        numberOfBars: @numberOfBars
      @appendChild view

    # DATE PAGINATOR
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
      parent: @
    @renderChildInto dateRangeView, @$el.find "#date-target"

    # If there are users not assigned to this project in the current company, show them here
    unassignedUsers = @model.getUnassignedUsers()
    unless unassignedUsers.isEmpty()
      @$el.append @addSomeone
        unassignedUsers: unassignedUsers.map (u) -> u.attributes
    @
