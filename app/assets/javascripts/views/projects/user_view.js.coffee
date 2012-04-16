class views.projects.UserView extends Support.CompositeView

  tagName: "div"
  className: "user"
    
  events:
    "click a.remove-user" : "removeUser"

  initialize: ->
    @userTemplate = Handlebars.compile(@templates.user)
    @headerTemplate = Handlebars.compile(@templates.work_week_header)
    
    @model.bind 'destroy', (project) =>
      @remove()
    
  render: ->
    meta = @model.collection.parent.view.dateRangeMeta()
    
    $( @el )
      .html( @userTemplate( user: @model.attributes ) )
      .find( '.months-and-weeks' )
      .html( @model.work_week_view.render().el )
    
    @
  
  dateRangeMeta: ->
    @options.parent.dateRangeMeta()
    
  templates:
    user: '''
    <div class='user-info'>
      <img src="{{user.gravatar}}" alt="{{user.first_name}} {{user.last_name}}" />
      <span class='name'>{{user.first_name}} {{user.last_name}}</span>
    </div>
    <div class='months-and-weeks'></div>
    '''
  
  removeUser: ->
    if confirm "Are you sure?  There is no undo (yet!)."
      @model.destroy()

views.projects.UserView= views.projects.UserView