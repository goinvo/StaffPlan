_templates =
  userItem: '''
    <div class="user-info fixed-180">
      <a href="/users/{{user.id}}">
        <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
        <span class='name'>
          <a href="/staffplans/{{user.id}}">{{user.first_name}} {{user.last_name}}</a>
        </span>
      </a>
      <div class="assignment-actions">
      </div>
    </div>
    <div class="user-hour-inputs flex">
    </div>
    <div class="totals fixed-60">
    </div>
  '''

StaffPlan.Templates.Assignments =
  userItem: Handlebars.compile _templates.userItem
