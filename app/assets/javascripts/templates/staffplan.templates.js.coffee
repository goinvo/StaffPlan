Handlebars.registerHelper 'staffplans_show_calendarYears', (dates) ->
  _.uniq(_.pluck dates, 'year').join("/<br/>")
      
Handlebars.registerHelper 'staffplans_show_calendarMonths', (dates) ->
  currentMonthName = null
      
  _.reduce dates, (html, date, index, dates) ->
    cell_content = ''
          
    unless currentMonthName?
      currentMonthName = date.xdate.toString 'MMM'
      cell_content += "<span class='month-name'>#{currentMonthName}</span>"
    else
      if date.xdate.toString('MMM') != currentMonthName
        currentMonthName = date.xdate.toString 'MMM'
        cell_content += "<span class='month-name'>#{currentMonthName}</span>"
        
    html += "<div>#{cell_content}</div>"
    html
        
  , ""
      
Handlebars.registerHelper 'staffplans_show_calendarWeeks', (dates) ->
  _.reduce dates, (html, date, index, dates) ->
    html += "<div>W#{Math.ceil(date.mday / 7)}</div>"
    html
  , ""


_templates = 
  show:
    frame: '''
    <div id="user-select" class="grid-row user-info padded">
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
    <div class='header grid-row padded'>
      <div class='grid-row-element fixed-180 title'><span>Client</span></div>
      <div class='grid-row-element fixed-180 title'><span>Project</span></div>
      <div class="grid-row-element flex date-range-target" id="interval-width-target"></div>
    </div>
    '''
  
    workWeeksAndYears: """
    <div class="cweeks-and-years"><div>{{{staffplans_show_calendarYears dates}}}</div>{{{staffplans_show_calendarMonths dates}}}</div>
    <div class="cweeks-and-years"><div></div>{{{staffplans_show_calendarWeeks dates}}}</div>
    """
    
    newClientAndProject: """
    <section class="client zebra" data-client-id="new">
      <div class="assignment-row grid-row padded">
        <div class="grid-row-element fixed-180 sexy">
          <input type="text" class="client-name-input input-medium" data-model="Client" data-attribute="name" data-trigger-save placeholder="Client Name" />
        </div>
        <div class="grid-row-element fixed-180 sexy">
          <input type="text" class="project-name-input input-medium" data-model="Project" data-attribute="name" data-trigger-save placeholder="Project Name" />
        </div>
        <div class="grid-row-element flex">
          <input type="button" class='btn btn-mini' data-trigger-save value="Save" />
        </div>
      </div>
    </section>
    """
  assignment:
    show: '''
      <div class="grid-row-element fixed-180 sexy">
        <div class='client-or-project-name'>{{clientName}}</div>
        {{#if showAddProject}}
        <a class='add-project return-false btn btn-mini' href="/staffplans/{{user_id}}"><i class='icon-plus-sign'></i>Add Project</a>
        {{/if}}
      </div>
      <div class="grid-row-element fixed-180 sexy">{{projectName}}</div>
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
      <input type="text" size="2" data-work-week-input data-current-value="{{estimated_hours}}" data-proposed="{{proposed}}" data-cweek="{{cweek}}" data-year="{{year}}" data-cid="{{cid}}" data-attribute="estimated_hours" value="{{estimated_hours}}" class='estimated-actual' />
      {{/each}}
    </div>
    <div class="grid-row flex">
      <div class='row-label'>Actual</div>
      {{#each visibleWorkWeeks}}
        {{#if hasPassedOrIsCurrent}}
        <input type="text" size="2" data-work-week-input data-current-value="{{actual_hours}} "data-proposed="{{proposed}}" data-cweek="{{cweek}}" data-year="{{year}}" data-cid="{{cid}}" data-attribute="actual_hours" value="{{actual_hours}}" class='estimated-actual' />
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
  work_week_row: Handlebars.compile _templates.work_week.row
}
