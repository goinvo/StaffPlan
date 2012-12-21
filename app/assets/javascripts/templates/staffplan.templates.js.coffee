Handlebars.registerHelper 'staffplans_show_calendarYears', (dates) ->
  _.uniq(_.pluck dates, 'year').join("/<br/>")
      
Handlebars.registerHelper 'staffplans_show_calendarMonths', (dates) ->
  currentMonthName = null
  _.reduce dates, (html, date, index, dates) ->
    cell_content = ''
          
    unless currentMonthName?
      currentMonthName = moment(date).format "MMM"
      cell_content += "<span class='month-name'>#{currentMonthName}</span>"
    else
      if moment(date).format('MMM') != currentMonthName
        currentMonthName = moment(date).format "MMM"
        cell_content += "<span class='month-name'>#{currentMonthName}</span>"
        
    html += "<div>#{cell_content}</div>"
    html
        
  , ""
      
Handlebars.registerHelper 'staffplans_show_calendarWeeks', (dates) ->
  _.reduce dates, (html, date, index, dates) ->
    html += "<div>W#{Math.ceil(moment(date).date() / 7)}</div>"
    html
  , ""
  
Handlebars.registerHelper 'hours_delta', (total) ->
  if total > 0 then "+#{total}" else "#{Math.abs(total)}"

_templates =
  index:
    pagination: '''
      <div class="date-paginator"> 
        <div class="fixed-180">
          <div class="btn-toolbar">
            <div class="btn-group">
              <a class="btn btn-mini{{#unless byWorkload}} btn-inverse{{/unless}}" title="Sort by name" data-key="field" data-value="name" data-bypass><i class="icon-user{{#unless byWorkload}} icon-white{{/unless}}"></i></a>
              <a class="btn btn-mini{{#if byWorkload}} btn-inverse{{/if}}" title="Sort by workload" data-key="field" data-value="workload" data-bypass><i class="icon-time{{#if byWorkload}} icon-white{{/if}}"></i></a>
              <a class="btn btn-mini" title="Toggle sort order" data-key="order" data-value="{{#if sortASC}}desc{{else}}asc{{/if}}" data-bypass><i class="{{#if sortASC}}icon-chevron-up{{else}}icon-chevron-down{{/if}}"></i></a>
            </div>
          </div>
          <a href="#" class="return-false previous pagination" data-action=previous>previous</a>
          <a href="#" class="return-false next pagination" data-action=next>next</a>

        </div>
        <div id="date-target" class="flex margin-left-20">
        </div>
      </div>
    '''
    addStaff: '''
    <div class="actions">
      <a class="btn btn-primary" href="/users/new">Add Staff</a>
    </div>
    '''
  show:
    frame: '''
    <div id="user-select" class="grid-row user-info padded">
      <div class="grid-row-element fixed-360">
        <img class="gravatar" src="{{user.gravatar}}" />
        <span class='name'>
          <a href="/users/{{user.id}}">{{user.full_name}}</a>
        </span>
      </div>
      <div id="user-chart" class="grid-row-element chart-wrapper top-0">
        <div class="flex chart-container margin-left-35"><svg class="user-chart"></svg></div>
      </div>
    </div>

    <div class='header grid-row padded'>
      <div class='grid-row-element fixed-180 title'><span>Client</span>
        <div class='btn-group pull-right'>
          <a href='#' class='btn btn-mini chill-out add-client' title="Add a new client and assignment for {{user.full_name}}"><i class='icon-plus-sign'></i></a>
        </div>
        
      </div>
      <div class='grid-row-element fixed-180 title'><span>Project</span></div>
      <div class="grid-row-element flex date-range-target date-paginator" id="interval-width-target"></div>
    </div>
    '''
  
    workWeeksAndYears: """
    <div class="cweeks-and-years"><div>{{{staffplans_show_calendarYears dates}}}</div>{{{staffplans_show_calendarMonths dates}}}</div>
    <div class="cweeks-and-years"><div></div>{{{staffplans_show_calendarWeeks dates}}}</div>
    """
  
  assignment:
    totals:
      """
      <div class='estimated-hours assignment-totals'>{{hours.estimated}}</div>
      <div class='actual-hours assignment-totals'>{{hours.actual}} <span class='pull-right'>&#916;{{hours_delta hours.delta}}</span></div>
      """
    actions:
      """
      <div class="btn-group">
        {{#if isDeletable}}
          <a href="#" class='btn btn-mini delete-assignment' title="Click to delete this assignment. This is permanent."><i class='icon-trash'></i></a>
        {{/if}}
        <a href="#" class="btn btn-mini {{#if archived}}btn-inverse {{/if}}toggle-archived" title="Click to {{#if archived}}un{{/if}}archive this assignment"><i class='{{#if archived}}icon-pause{{else}}icon-play{{/if}}{{#if archived}} icon-white{{/if}}'></i></a>
        <a href="#" class='btn btn-mini {{#if proposed}}btn-inverse {{/if}}toggle-proposed' title="Make this assignment's hours {{#if proposed}}planned{{else}}proposed{{/if}}"><i class='icon-time{{#if proposed}} icon-white{{/if}}'></i></a>
      </div>
      {{#if displayReassign}}
        <div class="btn-group btn-mini">
          <button class="btn btn-mini dropdown-toggle" title="Reassign to another user" data-toggle="dropdown">
            <i class="icon-user"></i>
            <span class="caret"></span>
          </button>
          <ul class="dropdown-menu" data-action=reassign>
            {{#each companyUsers}}
              <li>
                <a href="#" data-user-id="{{id}}">{{fullName}}</a>
              </li>
            {{/each}}
          </ul>
        </div>
      {{/if}}
      
      """
    show: '''
      <div class="grid-row-element client-name-and-project-name fixed-180 sexy">
        <a href="/clients/{{client.id}}">{{client.name}}</a>
        {{#if showAddProject}}
        <div class='btn-group pull-right'>
          <a class='add-project btn btn-mini' title="Click to add a new project assignment for {{client.name}}."><i class='icon-plus-sign'></i></a>
        </div>
        {{/if}}
      </div>
      <div class="grid-row-element fixed-180 sexy client-name-and-project-name assignment-actions-target">
        <a href="/projects/{{project.id}}">{{project.name}}</a>
      </div>
      <div class="grid-row-element flex work-weeks"></div>
    '''
    
    new: '''
    <div class="grid-row-element fixed-180 sexy">
      {{#if showClientInput}}
        <input type="text" class="client-name-input input-medium" data-model="Client" data-attribute="name" data-trigger-save placeholder="Client Name" />
      {{/if}}
    </div>
    <div class="grid-row-element fixed-180 sexy">
      <input type="text" class="project-name-input input-medium" data-model="Project" data-attribute="name" data-trigger-save placeholder="Project Name" />
    </div>
    <div class="grid-row-element flex">
      <input type="button" class='btn btn-mini' data-trigger-save value="Save" />
    </div>
    '''
  listItem: '''
    <div class='user-info fixed-180' data-user-id="{{user.id}}>
      <a href="/staffplans/{{user.id}}">
        <img alt="{{user.full_name}}" class="gravatar" src="{{user.gravatar}}" />
        <span class='name'>
          <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
        </span>
      </a>
    </div>
    <div class="chart-container flex">
      <svg class="user-chart"></svg>
    </div>
    <div class="totals fixed-60"></div>
    '''
  work_week:
    row: '''
    <div class='row-filler'>
      <a href='#'>&rarr;</a>
    </div>
    <div class="grid-row flex">
      <div class='row-label'>Plan</div>
      {{#each visibleWorkWeeks}}
        {{#if highlight}}
      <input type="text" size="2" data-work-week-input data-current-value="{{estimated_hours}}" data-proposed="{{proposed}}" data-timestamp="{{beginning_of_week}}" data-cid="{{cid}}" data-attribute="estimated_hours" value="{{estimated_hours}}" class='estimated-actual current-week-highlight' />
        {{else}}
      <input type="text" size="2" data-work-week-input data-current-value="{{estimated_hours}}" data-proposed="{{proposed}}" data-timestamp="{{beginning_of_week}}" data-cid="{{cid}}" data-attribute="estimated_hours" value="{{estimated_hours}}" class='estimated-actual' />
        {{/if}}
      {{/each}}
    </div>
    <br/>
    <div class="grid-row flex">
      <div class='row-label'>Actual</div>
      {{#each visibleWorkWeeks}}
        {{#if hasPassedOrIsCurrent}}
          {{#if highlight}}
        <input type="text" size="2" data-work-week-input data-current-value="{{actual_hours}} data-proposed="{{proposed}}" data-timestamp="{{beginning_of_week}}" data-cid="{{cid}}" data-attribute="actual_hours" value="{{actual_hours}}" class='estimated-actual current-week-highlight' />
          {{else}}
        <input type="text" size="2" data-work-week-input data-current-value="{{actual_hours}} data-proposed="{{proposed}}" data-timestamp="{{beginning_of_week}}" data-cid="{{cid}}" data-attribute="actual_hours" value="{{actual_hours}}" class='estimated-actual' />
          {{/if}}
        {{/if}}
      {{/each}}
    </div>
    '''

StaffPlan.Templates.StaffPlans = {
  index:
    addStaff: Handlebars.compile _templates.index.addStaff
    pagination: Handlebars.compile _templates.index.pagination
  listItem: Handlebars.compile _templates.listItem
  show_frame: Handlebars.compile _templates.show.frame
  show_workWeeksAndYears: Handlebars.compile _templates.show.workWeeksAndYears
  show_newClientAndProject: Handlebars.compile _templates.show.newClientAndProject
  assignment_show: Handlebars.compile _templates.assignment.show
  assignment_new: Handlebars.compile _templates.assignment.new
  assignment_actions: Handlebars.compile _templates.assignment.actions
  assignment_totals: Handlebars.compile _templates.assignment.totals
  work_week_row: Handlebars.compile _templates.work_week.row
}
