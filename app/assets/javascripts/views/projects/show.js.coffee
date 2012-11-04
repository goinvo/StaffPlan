class StaffPlan.Views.Projects.Show extends Support.CompositeView
  className: "project-show"
  templates:
    header: '''
      <div class="project-header row-fluid">
        <div class="project-info span2">
          {{name}} - {{date}}
          <div id="pagination">
            <a class="pagination" data-action=previous href="#">Previous</a>
            <a class="pagination" data-action=next href="#">Next</a>
          </div>
        </div>
        <div class="chart-container span10">
          <svg class="user-chart">
          </svg>
        </div>
      </div>
    '''
    mainContent: '''
      <div class="user-list row-fluid">
        <ul class="slick no-margin">
        </ul>
      </div>
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

    @startDate = new XDate()
    @headerTemplate = Handlebars.compile(@templates.header)
    @mainContent = Handlebars.compile(@templates.mainContent)
    @addSomeone = Handlebars.compile(@templates.addSomeone)
    
    # Create all the aggregates for that project and populate
    @aggregates = new StaffPlan.Collections.WeeklyAggregates [],
      parent: @model
      begin: @startDate.getTime()
      end: @startDate.clone().addWeeks(30).getTime()
    @aggregates.populate()
    

  events: ->
    "click div#pagination a.pagination": "paginate"
    "click a[data-action=add-user]": "addUserToProject"
    "click a[data-action=delete]": "deleteAssignment"

  paginate: (event) ->
    event.preventDefault()
    event.stopPropagation()
    delta = if ($(event.target).data('action') is "previous") then -30 else 30
    @startDate.addWeeks(delta)
    @render()

  deleteAssignment: ->

    event.preventDefault()
    event.stopPropagation()
    # TODO: Need that stupid closest because the source of the event can be the i used by
    # Bootstrap for the button icon. Might be a better way
    user = StaffPlan.users.get($(event.target).closest('a[data-action=delete]').data('user-id'))
    assignment = user.assignments.detect (assignment) => @model.id is assignment.get "project_id"
    deleteView = new window.StaffPlan.Views.Shared.DeleteModal
      model: assignment
      collection: user.assignments
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
    targetUser.assignments.create
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
    
    @$el.append @headerTemplate
      name: @model.get "name"
      date: new XDate(@startDate).getWeek() + " " + new XDate(@startDate).getFullYear()
    
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    numberOfBars = Math.round(chartContainerWidth / 40) - 2

    @aggregates = new StaffPlan.Collections.WeeklyAggregates [],
      parent: @model
      begin: @startDate.getTime()
      end: @startDate.clone().addWeeks(30).getTime()
    @aggregates.populate()
    console.log @aggregates.getBiggestTotal()
    @projectChartView = new StaffPlan.Views.WeeklyAggregates
      maxHeight: @aggregates.getBiggestTotal()
      collection: @aggregates#.takeSliceFrom(@startDate.getWeek(), @startDate.getFullYear(), numberOfBars)
      el: @$el.find("svg.user-chart")
      width: chartContainerWidth
    
    @projectChartView.render()
    
    @$el.append @mainContent

    @model.getAssignments().each (assignment) =>
      view = new StaffPlan.Views.Assignments.ListItem
        model: assignment
        parent: @model
        start: @startDate
        numberOfBars: numberOfBars
      @$el.find('ul.slick').append view.render().el

    # If there are users not assigned to this project in the current company, show them here
    unassignedUsers = @model.getUnassignedUsers()
    unless unassignedUsers.isEmpty()
      @$el.append @addSomeone
        unassignedUsers: unassignedUsers.map (u) -> u.attributes
    @$el.appendTo "section.main"

    @