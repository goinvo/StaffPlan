class views.projects.ProjectView extends views.shared.DateDrivenView
  
  className: 'project-users'
  id: "project-users"
  
  initialize: ->
    views.shared.DateDrivenView.prototype.initialize.call(this)
    
    @projectTemplate = Handlebars.compile(@templates.project)
    @headerTemplate = Handlebars.compile(@templates.work_week_header)
    @addSomeoneTemplate = Handlebars.compile(@templates.add_someone)
    Handlebars.registerHelper "addSomeoneLink", -> new Handlebars.SafeString "<a href='#' class='add-someone'>Add Someone</a>"
    
    @model.users.bind 'add', (newUser) =>
      @initUser newUser
      @render()
    
    @model.users.bind 'reset', (newUsers) =>
      newUsers.each (newUser) => @initUser newUser
      @render()
      
    @model.users.each (user) =>
      @initUser user
    
  
  initUser: (user) ->
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
    {{addSomeoneLink}}
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
    $( event.currentTarget ).closest( '.add-new-someone' ).remove();
    
  addNewSomeoneSubmit: (event) ->
    newUserId = parseInt $('#newSomeone').val(), 10
    companyUser = window._meta.users.detect (user) -> user.get('id') == newUserId
    
    @model.users.create companyUser.attributes,
      wait: true
      success: (project, response) =>
        @model.users.reset response.users.map (userString) -> JSON.parse(userString)
        @render()
        
      error: (project, response) =>
        alert("Couldn't save that user to the project, sorry.")
        @model.users.remove companyUser
        @render()
        
    false
  
window.views.projects.ProjectView = views.projects.ProjectView
