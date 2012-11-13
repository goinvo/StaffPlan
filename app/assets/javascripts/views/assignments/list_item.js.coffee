class StaffPlan.Views.Assignments.ListItem extends Support.CompositeView
  className: "user-list-item row-fluid"
  templates:
    userItem: '''
      <div class="user-info span2">
        <a href="/users/{{user.id}}">
          <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
          <span class='name'>
            <a href="/staffplans/{{user.id}}">{{user.first_name}} {{user.last_name}}</a>
          </span>
        </a>
      </div>
      <div class="user-hour-inputs span10">
      </div>
    '''

  updateWorkWeeksView: (begin) ->
    @workWeeksView.collection = @model.work_weeks.between(begin, begin + @numberOfBars * 7 * 86400 * 1000)
    @workWeeksView.render()

  initialize: ->
    StaffPlan.Dispatcher.on "date:changed", (message) =>
      @updateWorkWeeksView(message.begin)
    @startDate = @options.start.valueOf()
    @userItemTemplate = Handlebars.compile @templates.userItem
    @parent = @options.parent
    @numberOfBars = @options.numberOfBars
  
  render: ->
    @$el.html @userItemTemplate
      user: StaffPlan.users.get(@model.get("user_id")).attributes
    @workWeeksView = new window.StaffPlan.Views.Projects.WorkWeeks
      collection: @model.work_weeks.between(@startDate, @startDate + @numberOfBars * 7 * 86400 * 1000)
      start: @startDate
      count: @numberOfBars
    @$el.find("div.user-hour-inputs").html @workWeeksView.render().el
    @
  
