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


_templates =
  show:
    frame: '''
    <div id="user-select" class="grid-row user-info padded position-fixed top-38 padding-top-30 width-100-percent">
      <div class="grid-row-element fixed-360">
        <img class="gravatar" src="{{user.gravatar}}" />
        <span class='name'>
          <a href="/staffplans/{{user.id}}">{{user.full_name}}</a>
        </span>
      </div>
      <div id="user-chart" class="grid-row-element flex chart-totals-view">
        <a class="previous flex" href="#" data-change-page='previous'>Previous</a>
          <ul>
          </ul>
        <a class="next flex" href="#" data-change-page='next'>Next</a>
      </div>
      <div class="grid-row-element"></div>
    </div>
    <div class='header grid-row padded top-130 position-fixed width-100-percent'>
      <div class='grid-row-element fixed-180 title'><span>Client</span><a href='#' class='return-false add-client'><i class='icon-plus-sign'></i></a></div>
      <div class='grid-row-element fixed-180 title'><span>Project</span></div>
      <div class="grid-row-element flex date-range-target" id="interval-width-target"></div>
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
      <div class='actual-hours assignment-totals'>{{hours.actual}} <span class='pull-right'>&#916;{{hours.delta}}</span></div>
      """
    actions:
      """
      <button class="btn btn-mini"><i class="icon-cog"></i></button>
      <button class="btn btn-mini dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></button>
      <ul class="dropdown-menu">
        {{#if isDeletable}}
          <li><a href="#" class='delete-assignment'><i class='icon-trash'></i> Delete</a></li>
        {{else}}
          <li><a href="#"><strike><i class='icon-trash'></i> Delete</strike></a></li>
        {{/if}}
        <li class="divider"></li>
        {{#if archived}}
        <li><a href="#" class="toggle-archived"><i class='icon-check'></i> Unarchive</a></li>
        {{else}}
        <li><a href="#" class="toggle-archived"><i class='icon-inbox'></i> Archive</a></li>
        {{/if}}
        <li class="divider"></li>
        {{#if proposed}}
          <li><a href="#" class='toggle-proposed'><i class='icon-ok-sign'></i> Make Actual</a></li>
        {{else}}
          <li><a href="#" class='toggle-proposed'><i class='icon-question-sign'></i> Make Proposed</a></li>
        {{/if}}
      </ul>
      """
    show: '''
      <div class="grid-row-element client-name-and-project-name fixed-180 sexy">
        {{clientName}}
        {{#if showAddProject}}
        <div class='btn-group pull-right'>
          <button class="btn btn-mini"><i class="icon-cog"></i></button>
          <button class="btn btn-mini dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></button>
          <ul class="dropdown-menu">
            <li><a class='add-project'><i class='icon-plus-sign'></i>Add Project</a></li>
            <li class="divider"></li>
            <li><a href="#" class='destroy-all-assignments return-false'><i class='icon-check'></i> Delete All Assignments</a></li>
            <li class="divider"></li>
            <li><a href="#" class='acrhive-all-assignments return-false'><i class='icon-ok-sign'></i> Archive All Assignments</a></li>
          </ul>
        </div>
        {{/if}}
      </div>
      <div class="grid-row-element fixed-180 sexy client-name-and-project-name assignment-actions-target">
        {{projectName}}
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
    
  work_week:
    row: '''
    <div class='row-filler'>
      <a href='#'>&rarr;</a>
    </div>
    <div class="grid-row flex">
      <div class='row-label'>Plan</div>
      {{#each visibleWorkWeeks}}
      <input type="text" size="2" data-work-week-input data-current-value="{{estimated_hours}}" data-proposed="{{proposed}}" data-timestamp="{{beginning_of_week}}" data-cid="{{cid}}" data-attribute="estimated_hours" value="{{estimated_hours}}" class='estimated-actual' />
      {{/each}}
    </div>
    <div class="grid-row flex">
      <div class='row-label'>Actual</div>
      {{#each visibleWorkWeeks}}
        {{#if hasPassedOrIsCurrent}}
        <input type="text" size="2" data-work-week-input data-current-value="{{actual_hours}} data-proposed="{{proposed}}" data-timestamp="{{beginning_of_week}}" data-cid="{{cid}}" data-attribute="actual_hours" value="{{actual_hours}}" class='estimated-actual' />
        {{/if}}
      {{/each}}
    </div>
    '''

StaffPlan.Templates.StaffPlans = {
  show_frame: Handlebars.compile _templates.show.frame
  show_workWeeksAndYears: Handlebars.compile _templates.show.workWeeksAndYears
  show_newClientAndProject: Handlebars.compile _templates.show.newClientAndProject
  assignment_show: Handlebars.compile _templates.assignment.show
  assignment_new: Handlebars.compile _templates.assignment.new
  assignment_actions: Handlebars.compile _templates.assignment.actions
  assignment_totals: Handlebars.compile _templates.assignment.totals
  work_week_row: Handlebars.compile _templates.work_week.row
}
