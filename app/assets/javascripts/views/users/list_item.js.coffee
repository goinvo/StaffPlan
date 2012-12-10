class window.StaffPlan.Views.Users.ListItem extends Support.CompositeView
  initialize: ->
    @model.on "change", (event) =>
      @render()

  render: ->
    @$el.html StaffPlan.Templates.Users.listItem.userListItem
      user: @model.attributes
    @
