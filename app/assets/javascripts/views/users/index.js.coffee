class window.StaffPlan.Views.Users.Index extends Support.CompositeView
  templates:
    userIndex: '''
    <h2>List of users for <a href="/companies/{{currentCompany.id}}">{{currentCompany.name}}</a></h2> 
    <ul class="user-list">  
      {{#each users}} 
        <li data-user-id={{this.id}}>
          <div class='user-info'>
            <a href="/users/{{this.id}}">
              <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{this.gravatar}}" />
              <span class='name'>
                <a href="/staffplans/{{this.id}}">{{this.full_name}}</a>
              </span>
            </a>
            <a href="/users/{{this.id}}">Show user's profile</a>
          </div>
          <div class="actions">
            <a href="/users/{{this.id}}" data-action="delete" data-user-id="{{this.id}}">Delete user</a>
          </div>
        </li>
      {{/each}}
    </ul>
    <a href="/users/new">Add Staff</a>
    '''
  initialize: ->
    @userInfoTemplate = Handlebars.compile @templates.userIndex
    
    @$el.html @userInfoTemplate
      users: @collection.map (user) -> user.attributes
      currentCompany: @options.currentCompany
      
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
    @$el.appendTo("section.main .content")

