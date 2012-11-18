class window.StaffPlan.Views.StaffPlans.Index extends Support.CompositeView
  
  templates:
    pagination: '''
      <div class="row">
        <div class="span2">
          <div class="btn-group">
            <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
                Sort By
              <span class="caret"></span>
            </a>
            <ul class="dropdown-menu sort-users">
              <li><a href="#" data-criterion=name data-order=asc>Name (ASC)</a></li>
              <li><a href="#" data-criterion=name data-order=desc>Name (DESC)</a></li>
              <li><a href="#" data-criterion=workload data-order=asc>Workload (ASC)</a></li>
              <li><a href="#" data-criterion=workload data-order=desc>Workload (DESC)</a></li>
            </ul>
          </div>
          <button class="btn btn-primary" data-filter=inactive>Toggle active</button>
        </div>
      </div>
      <div class="row-fluid date-paginator"> 
        <div class="span2">
          <a href="#" class="pagination" data-action=previous>Previous</a>
          <a href="#" class="pagination" data-action=next>Next</a>
        </div>
        <div id="date-target" class="span10">
        </div>
      </div>
    '''
    addStaff: '''
    <div class="actions">
      <a class="btn btn-primary" href="/users/new">Add Staff</a>
    </div>
    '''
  events:
    "click div.date-paginator a.pagination": "paginate"
    "click ul.dropdown-menu.sort-users li a": "sortUsers"
    "click button.btn-primary[data-filter]": "toggleFilter"
 
  toggleFilter: (event) ->
    filter = localStorage.getItem("staffplanFilter")
    models = if filter is "inactive" then StaffPlan.users.active() else StaffPlan.users.inactive()
    localStorage.setItem("staffplanFilter", if filter is "active" then "inactive" else "active")
    @users.reset models

  sortUsers: (event) ->
    event.stopPropagation()
    event.preventDefault()
    target = $(event.target)
    [criterion, order] = [target.data('criterion'), target.data('order')]
    sorted = switch criterion
      when "workload"
        @users.sortBy (user) -> user.workload()
      when "name"
        @users.sortBy (user) -> user.get("last_name")
    @users.reset (if order is "asc" then sorted else sorted.reverse())

  leave: ->
    @off()
    @remove()

  paginate: (event) ->
    event.preventDefault()
    event.stopPropagation()
    if $(event.target).data('action') is "previous"
      @startDate.subtract('weeks', @numberOfBars)
    else
      @startDate.add('weeks', @numberOfBars)
    StaffPlan.Dispatcher.trigger "date:changed",
      begin: @startDate.valueOf()
      count: @numberOfBars

  initialize: ->
    localStorage.setItem("staffplanFilter", "active")
    @users = new StaffPlan.Collections.Users @options.users.active()
    m = moment()
    @startDate = m.utc().startOf('day').subtract('days', m.day() - 1)
    @users.bind "reset", (event) =>
      @render()
   

      
    StaffPlan.Dispatcher.on "membership:disable", (message) =>
      user = @users.detect (user) -> user.id is message.userId
      user.membership.save
        disabled: not user.membership.get("disabled")
      , success: (model, response) =>
          $(message.subview.el).slideUp 400, "linear", () ->
            $(@).remove()
      , error: (model, response) ->
          alert "FAIL"
      
    StaffPlan.Dispatcher.on "membership:archive", (message) =>
      user = @users.detect (user) -> user.id is message.userId
      user.membership.save
        archived: not user.membership.get("archived")
      , success: (model, response) =>
          $(message.subview.el).slideUp 400, "linear", () ->
            $(@).remove()
      , error: (model, response) ->
          alert "FAIL"

  render: ->
    @$el.empty()
    fragment = document.createDocumentFragment()
    @$el.append Handlebars.compile @templates.pagination
    @users.each (user) =>
      view = new StaffPlan.Views.StaffPlans.ListItem
        model: user
        startDate: @startDate.valueOf()
      fragment.appendChild view.render().el
    @$el.append $(fragment)
    @$el.append Handlebars.compile @templates.addStaff
    @$el.appendTo('section.main')
    
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    @numberOfBars = Math.round(chartContainerWidth / 40) - 2
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    @$el.find("#date-target").html dateRangeView.render().el
    m = moment()
    timestamp = m.utc().startOf("day").subtract("days", m.day() - 1).valueOf()
    @
