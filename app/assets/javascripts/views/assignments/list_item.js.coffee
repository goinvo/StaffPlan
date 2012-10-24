class StaffPlan.Views.Assignments.ListItem extends Support.CompositeView 
  templates:
    userItem: '''
      <li class="user-list-item" data-user-id={{user.id}}>
        <div class='user-info'>
          <a href="/users/{{user.id}}">
            <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
            <span class='name'>
              <a href="/staffplans/{{user.id}}">{{user.first_name}} {{user.last_name}}</a>
            </span>
          </a>
        </div>
        <div class="controls">
          <a class="btn btn-danger btn-small" data-action="delete" data-user-id={{user.id}}>
            <i class="icon-trash icon-white"></i>
            Delete
          </a>
        </div>
      </li>
      '''

  initialize: ->
    @userItemTemplate = Handlebars.compile @templates.userItem 

  render: ->
    @$el.html @userItemTemplate
      user: @model.attributes
    @
