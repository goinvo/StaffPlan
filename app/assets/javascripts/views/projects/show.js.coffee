class StaffPlan.Views.Projects.Show extends Support.CompositeView
  tagName: "ul"
  templates:
    header: '''
      <h3>
        {{name}}
        <div id="pagination">
          <a class="pagination" data-action=previous href="#">Previous</a>
          <a class="pagination" data-action=next href="#">Next</a>
      </h3>
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
    @addSomeone = Handlebars.compile(@templates.addSomeone)

  events: ->
    "click div#pagination a.pagination": "paginate"
    "click a[data-action=add-user]": "addUserToProject"
    "click a[data-action=delete]": "deleteAssignment"

  paginate: (event) ->
    delta = if ($(event.target).data('action') is "previous") then -10 else 10
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
    unassignedUsers = @model.getUnassignedUsers()

    @$el.empty()

    @$el.append @headerTemplate
      name: @model.get "name"
    
    @model.getAssignments().each (assignment) =>
      view = new StaffPlan.Views.Assignments.ListItem
        model: assignment
        parent: @model
        start: @startDate
      @$el.append view.render().el
    # If there are users not assigned to this project in the current company, show them here
    unless unassignedUsers.isEmpty()
      @$el.append @addSomeone
        unassignedUsers: unassignedUsers.map (u) -> u.attributes
    @$el.appendTo "section.main"

    @
