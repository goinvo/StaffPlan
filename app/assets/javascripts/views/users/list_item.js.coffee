class window.StaffPlan.Views.Users.ListItem extends Backbone.View
  templates:
    userListItem: '''
    <li class="user-list-item" data-user-id="{{user.id}}">
      <div class='user-info'>
        <a href="/users/{{user.id}}">
          <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
          <span class='name'>
            <a href="/staffplans/{{user.id}}">{{user.first_name}} {{user.last_name}}</a>
          </span>
        </a>
      </div>
      <div class="controls">
        <div class="btn-group">
          <a class="btn btn-info" data-action="show" data-user-id="{{user.id}}" href="/users/{{user.id}}">
            Show
          </a>
          <a class="btn btn-inverse" data-action="edit" data-user-id="{{user.id}}" href="/users/{{user.id}}/edit">
            <i class="icon-edit icon-white"></i>
            Edit
          </a>
          <a class="btn btn-danger" data-action="delete" data-user-id="{{user.id}}">
            <i class="icon-trash icon-white"></i>
            Delete
          </a>
        </div>
      </div>
    </li>
    '''

  initialize: ->
    @model.on "change", (event) =>
      @render()
    @userListItemTemplate = Handlebars.compile @templates.userListItem
    @render()

  render: ->
    @$el.html @userListItemTemplate
      user: @model.attributes
    @
