class window.StaffPlan.Views.StaffPlans.Assignment extends Backbone.View
  className: "assignment-row grid-row padded"
  tagName: "div"
  
  templates:
    show: '''
      <div class="grid-row-element fixed-180 sexy">
        <div class='client-or-project-name'>{{clientName}}</div>
        {{#if showAddProject}}
        <span class='plus-with-text'>
          <a class='add-project return-false' href="/staffplans/{{user_id}}">
            <i class='icon-plus'>&nbsp;</i>
            <span class='text'>Project</span>
          </a>
        </span>
        {{/if}}
      </div>
      <div class="grid-row-element fixed-180 sexy">{{projectName}}</div>
      <div class="grid-row-element flex work-weeks"></div>
    '''
    
    new: '''
    <div class="grid-row-element fixed-180 sexy">
      {{#if showClientInput}}
        <input type="text" class="client-name-input input-medium" data-model="Client" data-attribute="name" data-trigger-save />
      {{/if}}
    </div>
    <div class="grid-row-element fixed-180 sexy">
      <input type="text" class="project-name-input input-medium" data-model="Project" data-attribute="name" data-trigger-save />
    </div>
    <div class="grid-row-element flex">
      <input type="button" class='btn' data-trigger-save value="Save" />
    </div>
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
      showAddProject: @index == 0
      clientName: if @index == 0 then @client?.get('name') else ""
      projectName: @project?.get('name')
      user_id: @user.id
    
  render: ->
    @$el.html (if @model.isNew() then @renderNew() else @renderShow())
      
    @ensureWorkWeekRange()
    
    @$el.find( 'div.work-weeks' ).append @workWeeksView.render().el
    
    @
  
  events:
    "click input[type='button'][data-trigger-save]": "onSaveTriggered"
    "keydown input[type='text'][data-trigger-save]": "onSaveTriggeredByKeydown"
  
  onSaveTriggeredByKeydown: (event) ->
    if event.keyCode == 13
      @onSaveTriggered(event)
  
  onSaveTriggered: (event) ->
    @model.save
      wait: true
      project_name: @$el.find('[data-model="Project"][data-attribute="name"]').val()
      client_name: @$el.find('[data-model="Client"][data-attribute="name"]').val()