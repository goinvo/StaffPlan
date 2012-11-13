class StaffPlan.Views.Projects.Show extends Support.CompositeView
  className: "project-show"
  templates:
    header: '''
      <div class="project-header row-fluid">
        <div class="project-info span2">
          {{name}}
        </div>
        <div class="chart-container span10">
          <svg class="user-chart">
          </svg>
        </div>
      </div>
      <div class="row-fluid date-paginator"> 
        <div class="span2">
          <a href="#" class="pagination" data-action=previous>Previous</a>
          <a href="#" class="pagination" data-action=next>Next</a>
        </div>
        <div id="date-target" class="span10">
        </div>
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
    
  events: ->
    "click div.date-paginator a.pagination": "paginate"
    "click a[data-action=add-user]": "addUserToProject"
    "click a[data-action=delete]": "deleteAssignment"

  paginate: (event) ->
    event.preventDefault()
    event.stopPropagation()
    if $(event.target).data('action') is "previous"
      @startDate.subtract('weeks', @numberOfBars)
    else
      @startDate.add('weeks', @numberOfBars)
    StaffPlan.Dispatcher.trigger "date:changed"
      begin: @startDate.valueOf()
      count: @numberOfBars

  deleteAssignment: ->

    event.preventDefault()
    event.stopPropagation()
    # TODO: Need that stupid closest because the source of the event can be the i used by
    # Bootstrap for the button icon. Might be a better way
    user = StaffPlan.users.get($(event.target).closest('a[data-action=delete]').data('user-id'))
    assignment = user.getAassignments().detect (assignment) =>
      @model.id is assignment.get "project_id"
    deleteView = new window.StaffPlan.Views.Shared.DeleteModal
      model: assignment
      collection: user.getAssignments()
      parentView: @

    @$el.append deleteView.render().el
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

    fragment = document.createDocumentFragment()
    
    # HEADER
    @$el.append @headerTemplate
      name: @model.get "name"
    
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    @numberOfBars = Math.round(chartContainerWidth / 40) - 2

    @projectChartView = new StaffPlan.Views.WeeklyAggregates
      # FIXME: Hardwired value in here for now
      maxHeight: 100
      begin: @startDate.valueOf()
      count: @numberOfBars
      model: @model
      el: @$el.find("svg.user-chart")
      width: chartContainerWidth
    
    @projectChartView.render()
    

    # THE USERS AND THEIR INPUTS
    @model.getAssignments().each (assignment) =>
      view = new StaffPlan.Views.Assignments.ListItem
        model: assignment
        parent: @model
        start: @startDate
        numberOfBars: @numberOfBars
      fragment.appendChild view.render().el
      true
    @$el.append $(fragment)

    # DATE PAGINATOR
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    @$el.find("#date-target").html dateRangeView.render().el

    # If there are users not assigned to this project in the current company, show them here
    unassignedUsers = @model.getUnassignedUsers()
    unless unassignedUsers.isEmpty()
      @$el.append @addSomeone
        unassignedUsers: unassignedUsers.map (u) -> u.attributes
    @$el.appendTo "section.main"

    @
