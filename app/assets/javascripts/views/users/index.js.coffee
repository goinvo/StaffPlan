class window.StaffPlan.Views.Users.Index extends Support.CompositeView
  tagName: 'ul'
  className: 'user-list'
  initialize: ->
    @collection.on "change", (model) =>
      #model.view.render()
  events:
    "click div.controls a[data-action=delete]": "deleteUser"
    "click div.controls a[data-action=edit]": "editUser"
    "click div.controls a[data-action=show]": "showUser"
    "click div.actions a[data-action=new]": "newUser"

  deleteUser: ->
    event.preventDefault()
    event.stopPropagation()
    userId = $(event.target).data("user-id")
    user = @collection.get(userId)
    user.destroy()
    @collection.remove(user)
    @$el.find('li[data-user-id=' + userId + ']').remove()

  newUser: ->

  editUser: (userId) ->

  showUser: (userId) ->
  
  render: ->
    @$el.empty()
    @collection.each (user) =>
      # For each element in the collection, create a subview
      view = new window.StaffPlan.Views.Users.ListItem
        model: user
      @$el.append view.render().el
    @$el.append "<div class=\"actions\"><a href=\"/users/new\" class=\"btn btn-primary\" data-action=\"new\"><i class=\"icon-list\"></i>Add user</a></div>"
    @$el.appendTo 'section.main div.content'

    @
