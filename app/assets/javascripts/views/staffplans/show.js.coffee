class window.StaffPlan.Views.StaffPlans.Show extends window.StaffPlan.Views.Shared.DateDrivenView
  className: "staffplan"
  tagName: "div"
  
  templates:
    frame: '''
    <div id="user-select" class="grid-row user-info">
      <div class="grid-row-element fixed-360">
        <img class="gravatar" src="{{user.gravatar}}" />
        <span class='name'>
          <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
        </span>
      </div>
      <div id="user-chart" class="grid-row-element flex"></div>
      <div class="grid-row-element"></div>
    </div>
    '''
  
  gatherClientsByAssignments: ->
    _.uniq @model.assignments.pluck( 'client_id' ).map (clientId) -> StaffPlan.clients.get clientId
    
  initialize: ->
    window.StaffPlan.Views.Shared.DateDrivenView.prototype.initialize.call(this)
    
    @model = @options.user
    @clients = new window.StaffPlan.Collections.Clients @gatherClientsByAssignments()
    @frameTemplate = Handlebars.compile @templates.frame
    @assignmentTemplate = Handlebars.compile @templates.assignment
    
    @$el.append( @frameTemplate( user: @model.attributes ) )
    
    @$el.append @clientViews = @clients.map (client) =>
      new window.StaffPlan.Views.StaffPlans.Client.Show
        model: client
        user: @model
        assignments: @model.assignments.select (assignment) -> assignment.get('client_id') == client.id
    
    @render()
    
  render: ->
    @$el.appendTo('section.main .content')
    @$el.append @clientViews.map (clientView) -> clientView.el