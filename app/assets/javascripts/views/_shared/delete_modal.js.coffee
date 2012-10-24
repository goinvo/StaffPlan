class window.StaffPlan.Views.Shared.DeleteModal extends Support.CompositeView
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
        Delete {{resourceName}}? 
      </h3>
    </div>
    '''
    body: '''
    <div class="modal-body">
      <p>This action cannot be undone, proceed with caution...</p>
    </div>
    '''
    actions: '''
    <div class="modal-footer">
      <a href="#" data-dismiss="modal" class="btn btn-warning">Delete {{resourceName}}</a>
      <a href="#" class="btn btn-info">Back to list of {{collectionName}}</a>
    </div>
    '''
  events:
    "click a.btn-warning": "deleteResource"
    "click a.btn-info": "showCollection"
    
  initialize: ->
    @parentView = @options.parentView
    
  deleteResource: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @collection.remove @model # Destroys the model as well, see app/assets/javascript/collections/users.js.coffee
    # FIXME: Dirty hack :/ We need assignments client-side and projects and users to only carry id
    if @parentView?
      @parentView.render()
    @remove()

  showCollection: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @$el.undelegate("a.btn.confirm", "click", "deleteResource")
    @$el.undelegate("a.btn.cancel", "click", "showCollection")
    @$el.modal("hide")
    @remove()

  render: =>
    @$el.append Handlebars.compile(@templates.header)
      resourceName: @model.NAME
    @$el.append Handlebars.compile(@templates.body)
    @$el.append Handlebars.compile(@templates.actions)
      resourceName: @model.NAME
      collectionName: @collection.NAME
    
    @


