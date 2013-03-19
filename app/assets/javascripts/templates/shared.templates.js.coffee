_templates =
  yearFilter: '''
    <div class="btn-group btn-mini">
      <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" data-bypass href="#">
        {{buttonText}}
        <span class="caret"></span>
      </a>
      <ul class="dropdown-menu">
        <li><a href="#" class="filter" data-bypass data-fy="all">All Years</a></li>
        {{#each relevantYears}}
          <li><a href="#" class="filter" data-bypass data-fy="{{this}}">FY {{this}}</a></li>
        {{/each}}
      </ul>
    </div>
  '''
  companySwitcher: '''
    <div class="btn-group btn-mini">
      <a class="btn btn-mini dropdown-toggle" data-toggle="dropdown" data-bypass href="#">
        {{currentCompanyName}}
        <span class="caret"></span>
      </a>
      <ul class="dropdown-menu">
        {{#each companies}}
          <li>
            <a href="#" data-company-id="{{id}}" class="switcher" data-bypass>
              {{name}}
            </a>
          </li>
        {{/each}}
      </ul>
    </div>
  '''

StaffPlan.Templates.Shared =
  yearFilter: Handlebars.compile _templates.yearFilter
  companySwitcher: Handlebars.compile _templates.companySwitcher
