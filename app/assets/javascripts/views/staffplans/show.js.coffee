class window.StaffPlan.Views.StaffPlans.Show extends window.StaffPlan.Views.Shared.DateDrivenView
  className: "staffplan"
  tagName: "div"
  
  templates:
    frame: '''
    <div id="user-select" class="grid-row user-info">
      <div class="grid-row-element">
        <img class="gravatar" src="{{user.gravatar}}" />
        <span class='name'>
          <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
        </span>
      </div>
      <div class="grid-row-element"></div>
      <div id="user-chart" class="grid-row-element"></div>
      <div class="grid-row-element"></div>
    </div>
    '''
    
    assignment: '''
    <div class="assignment-row grid-row">
      <div class="grid-row-element">{{client.name}}</div>
      <div class="grid-row-element">{{project.name}}</div>
      <div class="grid-row-element">work weeks</div>
      <div class="grid-row-element">controls</div>
    </div>
    '''
    
  initialize: ->
    @user = @options.user
    @frameTemplate = Handlebars.compile @templates.frame
    @assignmentTemplate = Handlebars.compile @templates.assignment
    
    window.StaffPlan.Views.Shared.DateDrivenView.prototype.initialize.call(this)
    
    @$el.append( @frameTemplate( user: @user.attributes ) )
    @$el.append( @user.assignments.map (assignment) =>
      @assignmentTemplate
        assignment: assignment
        project: StaffPlan.projects.get( assignment.get( 'project_id' ) ).attributes
        client: StaffPlan.clients.get( assignment.get( 'client_id' ) ).attributes
    )
    @render()
    
  render: ->
    @$el.appendTo('section.main .content')
    