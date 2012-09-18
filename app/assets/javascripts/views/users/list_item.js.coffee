class window.StaffPlan.Views.Users.ListItem extends Backbone.View
  tagName: "li"

  templates:
    userListItem: '''
    <div class='user-info'>
      <a href="/users/{{user.id}}">
        <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
        <span class='name'>
          <a href="/staffplans/{{user.id}}">{{user.first_name}} {{user.last_name}}</a>
        </span>
      </a>
      <a href="/users/{{user.id}}">Show user's profile</a>
      <a href="/users/{{user.id}}/edit">Edit user's profile</a>
    </div>
    <div class="actions">
      <a href="/users/{{user.id}}" data-action="delete" data-user-id="{{user.id}}">Delete user</a>
    </div>
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
