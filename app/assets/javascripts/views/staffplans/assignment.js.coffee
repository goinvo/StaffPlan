class window.StaffPlan.Views.StaffPlans.Assignment extends Backbone.View
  className: "assignment-row grid-row padded"
  tagName: "div"
  
  templates:
    show: '''
      <div class="grid-row-element fixed-180 sexy">
        <span>{{clientName}}</span>
        {{#if clientName}}
          <a class='action-right add-project btn btn-mini return-false' onclick="return false;" href="/staffplans/{{user_id}}">Add Project</a>
        {{/if}}
      </div>
      <div class="grid-row-element fixed-180 sexy">{{projectName}}</div>
      <div class="grid-row-element flex work-weeks"></div>
    '''
    
    new: '''
    <div class="grid-row-element fixed-180 sexy">
      <span>{{clientName}}</span>
      {{#if clientName}}
        <a class='action-right add-project btn btn-mini return-false' href="#">Add Project</a>
      {{/if}}
    </div>
    <div class="grid-row-element fixed-180 sexy">{{projectName}}</div>
    <div class="grid-row-element flex work-weeks"></div>
    '''
    
  initialize: ->
    @model = @options.model
    @client = @options.client
    @user = @options.user
    @index = @options.index
    @project = StaffPlan.projects.get( @model.get 'project_id' )
    
    @showTemplate = Handlebars.compile @templates.show
    @newTemplate = Handlebars.compile @templates.new
    
    @$el.data('cid', @cid)
    
    @workWeeksView = new window.StaffPlan.Views.StaffPlans.WorkWeeks
      collection: @model.work_weeks
      user: @user
    
  ensureWorkWeekRange: =>
    for meta in @user.view.getYearsAndWeeks()
      unless _.any(@model.work_weeks.where({cweek: meta.cweek, year: meta.year}))
        @model.work_weeks.add
          cweek: meta.cweek
          year: meta.year
  
  renderNew: ->
    @newTemplate
      showClientInput: @client.isNew()
  
  renderShow: ->
    @showTemplate
      clientName: if @index == 0 then @client?.get('name') else ""
      projectName: @project?.get('name')
      user_id: @user.id
    
  render: ->
    @$el.html (if @model.isNew() then @renderNew() else @renderShow())
      
    @ensureWorkWeekRange()
    
    @$el.find( 'div.work-weeks' ).append @workWeeksView.render().el
    
    @