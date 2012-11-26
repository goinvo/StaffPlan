class window.StaffPlan.Views.Users.Index extends Support.CompositeView
  tagName: 'ul'
  className: 'user-list slick'
  
  initialize: ->
    @collection.bind "remove", () =>
      @render()

  events:
    "click div.controls a[data-action=delete]": "deleteUser"
    "click div.controls a[data-action=edit]": "editUser"
    "click div.controls a[data-action=show]": "showUser"
    "click div.actions a[data-action=new]": "newUser"

  deleteUser: ->
    event.preventDefault()
    event.stopPropagation()
    userId = $(event.target).data("user-id")
    deleteView = new window.StaffPlan.Views.Shared.DeleteModal
      model: @collection.get(userId)
      collection: @collection
    @$el.append deleteView.render().el
    $('#delete_modal').modal
      show: true
      keyboard: true
      backdrop: 'static'

  newUser: ->

  editUser: (userId) ->

  showUser: (userId) ->
  
  render: ->
    @$el.empty()
    @$el.append StaffPlan.Templates.Users.index.header
    @collection.each (user) =>
      # For each element in the collection, create a subview
      view = new window.StaffPlan.Views.Users.ListItem
        model: user
      @$el.append view.render().el
    @$el.append StaffPlan.Templates.Users.index.actions.addUser
    @$el.appendTo 'section.main'

    @
