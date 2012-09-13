class window.StaffPlan.Views.Users.Show extends Support.CompositeView
  templates:
    userInfo: '''
    <div class='user-profile'>
      <a href="/staffplans/{{user.id}}">
        <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
      </a>
      <h2>Full Name</h2>
      <a href="/staffplans/{{user.id}}">
        <div class="user-name"> 
          <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
        </h2>
      </a>
      <h2>Email</h2>
      <div class='user-email'>
        {{user.email}}
      </div>
      <h2>List of projects</h2>
      <div class='user-projects'>
        <ul class='user-projects-list'>
        {{#each projects}}
          <li class="user-projects-list-item">
            <a href="/projects/{{this.projectId}}">{{this.projectName}}</a>
          </li>
        {{/each}}
        </ul>
      </div>
    </div>
    <a href="/users">Back to list of users</a>
    '''
  
  initialize: ->
    @userInfoTemplate = Handlebars.compile(@templates.userInfo)
    userProjects = @model.get('assignments')?.map (assignment) ->
      projectId: assignment.project_id
      projectName: window.StaffPlan.projects.get(assignment.project_id).get('name')
    @$el.html @userInfoTemplate
      user: @model.attributes 
      projects: userProjects
      
    @render()
    
  render: ->
    @$el.appendTo('section.main .content')

