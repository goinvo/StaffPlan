class window.StaffPlan.Views.Users.Index extends Support.CompositeView
  tagName: 'ul'
  className: 'user-list'
  initialize: ->
    @collection.on "change", (model) =>
      @render()
  events:
    "click div.actions a[data-action=delete]": "deleteUser"

  deleteUser: ->
    event.preventDefault()
    event.stopPropagation()
    userId = $(event.target).data("user-id")
    console.log @collection
    user = @collection.get(userId)
    user.destroy()
    @collection.remove(user)
    @$el.find('li[data-user-id=' + userId + ']').remove()

  
  render: ->
    @collection.each (user) =>
      # For each element in the collection, create a subview
      view = new window.StaffPlan.Views.Users.ListItem
        model: user
      @$el.append view.render().el
    
    @$el.appendTo 'section.main div.content'

    @
