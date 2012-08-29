class window.StaffPlan.Views.StaffPlans.Index extends Support.CompositeView
  templates:
    userInfo: '''
    <li>
      <div class='user-info'>
        <a href="/staffplans/{{user.id}}">
          <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
          <span class='name'>
            <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
          </span>
        </a>
      </div>
      <ul class='week-hour-counter'></ul>
    </li>
    '''
  
  initialize: ->
    @users = @options.users
    @userInfoTemplate = Handlebars.compile(@templates.userInfo)
    
    @$el.html @users.map (user) => @userInfoTemplate user: user.attributes
      
    @render()
    
  render: ->
    @$el.appendTo('section.main .content')
    