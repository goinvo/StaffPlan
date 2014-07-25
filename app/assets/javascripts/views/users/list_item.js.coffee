class window.StaffPlan.Views.Users.ListItem extends Support.CompositeView
  tagName: "li"
  className: "user-list-item list-item"
    
  initialize: ->
    @$el.data
      "user-id": @model.get('id')
    
    @model.on "change", (event) =>
      @render()

  render: ->
    @$el.html HandlebarsTemplates["users/list_item"]
      user: @model.attributes
    @
