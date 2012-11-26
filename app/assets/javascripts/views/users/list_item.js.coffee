class window.StaffPlan.Views.Users.ListItem extends Backbone.View
  initialize: ->
    @model.on "change", (event) =>
      @render()

  render: ->
    @$el.html StaffPlan.Templates.Users.listItem.userListItem
      user: @model.attributes
    @
