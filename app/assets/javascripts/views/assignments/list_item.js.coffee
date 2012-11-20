class StaffPlan.Views.Assignments.ListItem extends Support.CompositeView
  className: "user-list-item list-item"
  templates:
    userItem: '''
      <div class="user-info fixed-180">
        <a href="/users/{{user.id}}">
          <img alt="A69309561cecae0e0210ace5f6a9a585" class="gravatar" src="{{user.gravatar}}" />
          <span class='name'>
            <a href="/staffplans/{{user.id}}">{{user.first_name}} {{user.last_name}}</a>
          </span>
        </a>
      </div>
      <div class="user-hour-inputs flex">
      </div>
    '''

  updateWorkWeeksView: (begin) ->
    @workWeeksView.collection = @model.work_weeks.between(begin, begin + @numberOfBars * 7 * 86400 * 1000)
    @workWeeksView.render()
  
  

  initialize: ->
    @startDate = @options.start.valueOf()
    @userItemTemplate = Handlebars.compile @templates.userItem
    @numberOfBars = @options.numberOfBars
    @on "date:changed", (message) =>
      @workWeeksView.trigger "date:changed", message
  
  render: ->
    @$el.html @userItemTemplate
      user: StaffPlan.users.get(@model.get("user_id")).attributes
    @workWeeksView = new window.StaffPlan.Views.Projects.WorkWeeks
      collection: @model.work_weeks
      start: @startDate
      count: @numberOfBars
    @renderChildInto @workWeeksView, @$el.find "div.user-hour-inputs"

    @
  
