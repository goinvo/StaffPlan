class window.StaffPlan.Views.StaffPlans.Assignment extends Backbone.View
  className: "assignment-row grid-row padded"
  tagName: "div"
  
  templates:
    row_children: '''
      <div class="grid-row-element fixed-180 sexy">{{clientName}}</div>
      <div class="grid-row-element fixed-180 sexy">{{projectName}}</div>
      <div class="grid-row-element flex work-weeks"></div>
    '''
    
  initialize: ->
    @model = @options.model
    @client = @options.client
    @user = @options.user
    @index = @options.index
    
    @project = StaffPlan.projects.get( @model.get( 'project_id' ) )
    
    @rowChildrenTemplate = Handlebars.compile @templates.row_children
    
    @$el.append @rowChildrenTemplate
      clientName: if @index == 0 then @client.get('name') else ""
      projectName: @project.get('name')
    
    @workWeeksView = new window.StaffPlan.Views.StaffPlans.WorkWeeks
      collection: @model.work_weeks
      user: @user
    
  ensureWorkWeekRange: =>
    for meta in @user.view.getYearsAndWeeks()
      unless _.any(@model.work_weeks.where({cweek: meta.cweek, year: meta.year}))
        @model.work_weeks.add
          cweek: meta.cweek
          year: meta.year
    
  render: ->
    @ensureWorkWeekRange()
    @$el.find( 'div.work-weeks' ).append @workWeeksView.render().el
    @
    
