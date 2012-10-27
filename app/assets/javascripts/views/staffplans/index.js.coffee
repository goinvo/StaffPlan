class window.StaffPlan.Views.StaffPlans.Index extends Support.CompositeView
  tagName: "div"
  className: "row-fluid"
  templates:
    userInfo: '''
    <div class="span12">
      <ul class="user-list unstyled slick">  
        {{#each users}} 
          <li>
            <div class='user-info'>
              <a href="/staffplans/{{this.id}}">
                <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{this.gravatar}}" />
                <span class='name'>
                  <a href="/staffplans/{{this.id}}">{{this.full_name}}</a>
                </span>
              </a>
            </div>
            <div class="controls">
              <a class="btn btn-info" href="/users/{{this.id}}">Show profile</a>
            </div>
            <ul class='week-hour-counter'></ul>
          </li>
        {{/each}}
      </ul>
      <div class="actions">
        <a class="btn btn-primary" href="/users/new">Add Staff</a>
      </div>
    </div>
    '''
  
  initialize: ->
    @users = @options.users
    @userInfoTemplate = Handlebars.compile @templates.userInfo
    
    @$el.html @userInfoTemplate
      users: @users.map (user) -> user.attributes
      
    @render()
    
  render: ->
    @$el.appendTo('section.main')
    
  leave: ->
    @off()
    @remove()
