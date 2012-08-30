class window.StaffPlan.Views.Users.Show extends Support.CompositeView
  templates:
    userInfo: '''
    <div class='user-profile'>
      <a href="/staffplans/{{user.id}}">
        <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
        <span class='name'>
          <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
        </span>
      </a>
      <div class='user-email'>
        {{user.email}}
      </div>
      <div class='user-projects'>
        List of projects:
          <ul class='user-projects-list'>
          {{#projects}}
            <li class="user-projects-list-item">
              {{.}}
            </li>
          {{/projects}}
          </ul>
      </div>
    </div>
    '''
  
  initialize: ->
    @userInfoTemplate = Handlebars.compile(@templates.userInfo)
    userProjects = @model.get('projects').map (project) ->
      window.StaffPlan.projects.get(project.project_id).get('name')
    @$el.html @userInfoTemplate({user: @model.attributes, projects: userProjects})
      
    @render()
    
  render: ->
    @$el.appendTo('section.main .content')

