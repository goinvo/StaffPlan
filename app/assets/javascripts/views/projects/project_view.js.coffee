class views.projects.ProjectView extends views.shared.DateDrivenView
  
  className: 'project-users'
  id: "project-users"
  
  initialize: ->
    views.shared.DateDrivenView.prototype.initialize.call(this)
    
    @projectTemplate = Handlebars.compile(@templates.project)
    @headerTemplate = Handlebars.compile(@templates.work_week_header)
    
    @model.users.each (user) =>
      user.view = new views.projects.UserView 
        model: user
        parent: @
      
      user.work_week_view = new views.projects.WorkWeekListView
        model: user.work_weeks
        parent: @
    
  render: ->
    meta = @dateRangeMeta()
    
    $( @el )
      .appendTo( 'section.main .content' )
      .html( @projectTemplate
        users: @model.get('users')
      )
      .find( '.date-pagination' )
      .html( @headerTemplate
        monthNames: (=>
          _.map meta.dates, (dateMeta, idx, dateMetas) ->
            name: if dateMetas[idx - 1] == undefined or dateMeta.month != dateMetas[idx - 1].month then _meta.abbr_months[ dateMeta.month - 1 ] else ""
          )()
        weeks: (=>
          _.map meta.dates, (dateMeta, idx, dateMetas) ->
            name: "W#{Math.ceil dateMeta.mday / 7}"
          )()
      )
      
    $( @el )
      .find( 'ul.users' )
      .append @model.users.map (user) -> user.view.render().el
    
    @
  
  templates:
    project: """
    <h3>Team Members:</h3>
    <div class='date-pagination'></div>
    <ul class='users'>
      {{#unless users}}}
        <li><em>None!</em></li>
      {{/unless}}
    </ul>
    """
    
    work_week_header: """
    <div class='plan-actual'>
      <div class='row-label'>&nbsp;</div>
      {{#monthNames}}
      <div>{{ name }}</div>
      {{/monthNames}}
      <div class='total'></div>
      <div class='diff-remove-project'></div>
    </div>
    <div class='plan-actual'>
      <div class='row-label'>&nbsp;</div>
      {{#weeks}}
      <div>{{ name }}</div>
      {{/weeks}}
      <div class='total'>Total</div>
      <div class='diff-remove-project'></div>
    </div>
    """
  
window.views.projects.ProjectView = views.projects.ProjectView
