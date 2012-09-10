class window.StaffPlan.Views.StaffPlans.Assignment extends Backbone.View
  className: "assignment-row grid-row padded"
  tagName: "div"
  
  templates:
    children: '''
      <div class="grid-row-element fixed-180">{{clientName}}</div>
      <div class="grid-row-element fixed-180">{{projectName}}</div>
      <div class="grid-row-element flex work-weeks"></div>
    '''
    
  initialize: ->
    @model = @options.model
    @client = @options.client
    @user = @options.user
    @index = @options.index
    
    @project = StaffPlan.projects.get( @model.get( 'project_id' ) )
    
    @childrenTemplate = Handlebars.compile @templates.children
    
    @work_weeks = @model.get('work_weeks').map (work_week) =>
      new window.StaffPlan.Views.StaffPlans.WorkWeeks
            model: work_week
            assignment: @model
            client: @client
            user: @user
    
    @$el.append @childrenTemplate
      clientName: if @index == 0 then @client.get('name') else ""
      projectName: @project.get('name')
    
    @$el.find( '.work-weeks' ).append @work_weeks.el
    
    
  render: ->
    @
    
