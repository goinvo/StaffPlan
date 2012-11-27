_templates =
  yearFilter: '''
    <select class="year-filter">
      <option value="0">Select year</option>
      {{#each relevantYears}}
        <option value="{{this}}">{{this}}</option>
      {{/each}}
    </select>
  '''

StaffPlan.Templates.Shared =
  yearFilter: Handlebars.compile _templates.yearFilter
