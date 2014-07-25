class window.StaffPlan.Views.Users.Index extends StaffPlan.View
  className: "short"
    
  initialize: ->
    @collection.bind "remove", =>
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
    super
    
    @$el.find('header').append HandlebarsTemplates["users/index/header"]
    
    @$el.find('section.main').append('<ul class="user-list slick short">')
    @collection.each (user) =>
      # For each element in the collection, create a subview
      view = new window.StaffPlan.Views.Users.ListItem
        model: user
      @appendChildTo view, @$el.find("section.main ul.slick")
    
    @$el.find('section.main ul').append HandlebarsTemplates["users/index/actions/add_user"]

    @
