class window.StaffPlan.Views.Users.Delete extends Support.CompositeView
  className: "modal"
  attributes:
    id: "delete_modal"
  templates:
    header: '''
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal">
        X
      </button>
      <h3>
        Delete user? 
      </h3>
    </div>
    '''
    body: '''
    <div class="modal-body">
      <p>This action cannot be undone, proceed with caution</p>
    </div>
    '''
    actions: '''
    <div class="modal-footer">
      <a href="#" data-dismiss="modal" class="btn btn-warning">Delete user</a>
      <a href="/users" class="btn btn-info">Back to list of users</a>
    </div>
    '''
  events:
    "click a.btn-warning": "deleteUser"
    "click a.btn-info": "userIndex"

  
    
    
  initialize: ->
  
  deleteUser: (event) ->
    @collection.remove @model # Destroys the model as well, see app/assets/javascript/models/users.js.coffee
    @remove()

  userIndex: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @$el.undelegate("a.btn.confirm", "click", "deleteUser")
    @$el.undelegate("a.btn.cancel", "click", "userIndex")
    @$el.modal("hide")
    @remove()

  render: ->
    @$el.append Handlebars.compile(@templates.header)
    @$el.append Handlebars.compile(@templates.body)
    @$el.append Handlebars.compile(@templates.actions)
    
    @


