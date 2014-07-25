class window.StaffPlan.Views.Shared.DeleteModal extends Support.CompositeView
  className: "modal"
  attributes:
    id: "delete_modal"
  
  events:
    "click a.btn-warning": "deleteResource"
    "click a.btn-info": "showCollection"
    
  initialize: (options={}) ->
    @parentView = options.parentView
    
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
    @$el.append HandlebarsTemplates["delete_modal/header"]
      resourceName: @model.NAME
    @$el.append HandlebarsTemplates["delete_modal/body"]
    @$el.append HandlebarsTemplates["delete_modal/actions"]
      resourceName: @model.NAME
      collectionName: @collection.NAME
    
    @
