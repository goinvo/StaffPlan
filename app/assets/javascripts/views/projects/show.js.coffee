class StaffPlan.Views.Projects.Show extends Support.CompositeView
  tagName: "ul"
  templates:
    header: '''
      <h3>
        {{name}}
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

    @headerTemplate = Handlebars.compile(@templates.header)
    @addSomeone = Handlebars.compile(@templates.addSomeone)

  events: ->
    "click a[data-action=add-user]": "addUserToProject"
    "click a[data-action=delete]": "deleteAssignment"
  
  deleteAssignment: ->
    
    event.preventDefault()
    event.stopPropagation()
    user = StaffPlan.users.get($(event.target).closest('a[data-action=delete]').data('user-id'))
    assignment = user.assignments.detect (a) =>
      a.get('project_id') is @model.id
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
        @render()
    , error: (model, response) ->
        alert "SOMETHING WENT WRONG"
  render: ->
    assignedUsers = StaffPlan.users.select (user) =>
      user.assignments.any (assignment) =>
        assignment.get("project_id") is @model.id
    
    unassignedUsers = _.difference StaffPlan.users.models, assignedUsers
    
    @$el.empty()
    # Header
    @$el.append @headerTemplate 
      name: @model.get "name"
      # List of assigned users
    _.each assignedUsers, (user) =>
      view = new StaffPlan.Views.Assignments.ListItem
        model: user 
      @$el.append view.render().el
    # Assign a user to the project
    # templateData = _.map unassignedUsers, (user) -> 
    #   user.attributes
    if unassignedUsers.length
      @$el.append @addSomeone
        unassignedUsers: (_.map unassignedUsers, (user) -> user.attributes) 
    @$el.appendTo "section.main"
    
    @
