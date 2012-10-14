class window.StaffPlan.Views.Users.Show extends Support.CompositeView
  templates:
    userInfo: '''
    <div class='user-profile'>
      <a href="/staffplans/{{user.id}}">
        <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
      </a>
      <h3>Full Name</h3>
      <a href="/staffplans/{{user.id}}">
        <div class="user-name"> 
          <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
        </h3>
      </a>
      <h3>Email</h3>
      <div class='user-email'>
        {{user.email}}
      </div>
      <h3>List of projects</h3>
      <div class='user-projects'>
        {{#each projects}}
          <p class="user-projects-list-item">
            <a href="/projects/{{this.projectId}}">{{this.projectName}}</a>
          </p>
        {{/each}}
      </div>
    </div>
    <a class="btn btn-primary" href="/users">Back to list of users</a>
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
    @$el.appendTo('section..main')

