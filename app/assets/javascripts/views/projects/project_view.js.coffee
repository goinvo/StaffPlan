class views.projects.ProjectView extends views.shared.DateDrivenView
  
  className: 'project-users'
  id: "project-users"
  
  initialize: ->
    views.shared.DateDrivenView.prototype.initialize.call(this)
    
    @container_selector = '#project-users > section.users .user:first .months-and-weeks'
    
    @projectTemplate = Handlebars.compile(@templates.project)
    @headerTemplate = Handlebars.compile(@templates.work_week_header)
    @addSomeoneTemplate = Handlebars.compile(@templates.add_someone)
    Handlebars.registerHelper "addSomeoneLink", -> new Handlebars.SafeString "<a href='#' class='add-someone'>Add Someone</a>"
    
    @model.users.bind 'add', (newUser) =>
      @initUser newUser
      @render()
    
    @model.users.bind 'reset', (newUsers) =>
      newUsers.each (newUser) => @initUser newUser
      @delayedOnWindowResized()
      
    @model.users.each (user) =>
      @initUser user
      
    $( document.body ).bind 'work_week:value:updated', =>
      @renderWeekHourCounter()
  
  initUser: (user) ->
    user.view = new views.projects.UserView
      model: user
      parent: @
      
    user.work_week_view = new views.projects.WorkWeekListView
      model: user.work_weeks
      parent: @
  
  renderWeekHourCounter: ->
    @weekHourCounter = new views.shared.ChartTotalsView @model.dateRangeMeta().dates, @model.users.models, ".project-header", @$ ".week-hour-counter"
    
  renderHeaderTemplate: (append=false) ->
    meta = @dateRangeMeta()
    html = @headerTemplate
      currentYear: ->
        new Date().getFullYear()
      monthNames: (=>
        _.map meta.dates, (dateMeta, idx, dateMetas) ->
          name: if dateMetas[idx - 1] == undefined or dateMeta.month != dateMetas[idx - 1].month then moment.monthsShort[ dateMeta.month - 1 ] else ""
        )()
      weeks: (=>
        _.map meta.dates, (dateMeta, idx, dateMetas) ->
          name: "W#{Math.ceil dateMeta.mday / 7}"
        )()
    
    if append
      @$el.find( '.date-pagination-header' ).html( html )
    else
      html
  
  renderContent: ->
    $( @el )
      .find( 'section.users' )
      .append @model.users.map (user) -> user.view.render().el
    
  render: ->
    $( @el )
      .appendTo( 'section.main .content' )
      .html( @projectTemplate
        clientName: window._meta.clients.detect((client) => client.get('id') == @model.get('client_id'))?.get('name')
        project: @model.attributes
        users: @model.get('users')
      )
      .find( '.date-pagination-header' )
      .html( @renderHeaderTemplate() )
    
    @$('div.date-pagination-header div.plan-actual:first .row-label').html @fromDate.year()
      
    @renderWeekHourCounter()
    
    @
  
  templates:
    project: """
    <div class='project-header'>
      <header>
        <h2>{{clientName}} : {{project.name}}</h2>
        (Cost: ${{project.cost}} {{project.payment_frequency}})
        <div class='actions'>
          <a href='/projects/{{project.id}}/edit'>Edit Project Details</a>
        </div>
      </header>
      <div class='date-pagination'>
        <a href='#' data-change-page='previous' class='previous'>&larr;</a>
        <ul class='week-hour-counter'></ul>
        <a href='#' data-change-page='next' class='next'>&rarr;</a>
      </div>
    </div>
    <div class='date-pagination-header'></div>
    <section class='users'>
      {{#unless users}}}
        <section class='none'><em>None!</em></section>
      {{/unless}}
    </section>
    {{addSomeoneLink}}
    """
    
    work_week_header: """
    <div class='plan-actual'>
      <div class='row-label'>{{ currentYear }}</div>
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
    
    add_someone: """
    <form class='add-new-someone'>
      <select id="newSomeone" name="someone">
        {{#each unassignedUsers}}
          <option value='{{this.id}}'>{{this.full_name}}</option>
        {{/each}}
      </select>
      <input type="submit" value="Add" />
      <a href="#" class="cancel-add-someone">nevermind</a>
    </form>
    """
  
  events:
    "click .add-someone" : "addSomeone"
    "click .cancel-add-someone" : "cancelAddSomeone"
    "submit form.add-new-someone" : "addNewSomeoneSubmit"
    "click a[data-change-page]" : "changePage"

  changePage: (event) ->
    @dateChanged event
    @render()
    @renderContent()
    
  addSomeone: ->
    @$( '.add-new-someone' ).remove()
    assignedUserIds = @model.users.pluck('id')
    
    unassignedUsers = window._meta.users.reject (user) =>
        _.include assignedUserIds, user.id
        
    @$el.append @addSomeoneTemplate
      unassignedUsers: unassignedUsers.map (user) ->
        id: user.get('id')
        full_name: user.get('full_name')
    
    setTimeout => @delegateEvents()
      
  
  cancelAddSomeone: (event) ->
    $( event.currentTarget ).closest( '.add-new-someone' ).remove()
    
  addNewSomeoneSubmit: (event) ->
    newUserId = parseInt $('#newSomeone').val(), 10
    companyUser = window._meta.users.detect (user) -> user.get('id') == newUserId
    
    @model.users.create companyUser.attributes,
      wait: true
      success: (project, response) =>
        @model.users.reset response.users.map (userString) -> JSON.parse(userString)
        # We don't have to render manually since the reset event on the collection triggers a refresh 
        # @render()
        
      error: (project, response) =>
        alert("Couldn't save that user to the project, sorry.")
        @model.users.remove companyUser
        @render()
        
    false
  
window.views.projects.ProjectView = views.projects.ProjectView
