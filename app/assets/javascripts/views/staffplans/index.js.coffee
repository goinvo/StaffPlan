class window.StaffPlan.Views.StaffPlans.Index extends Support.CompositeView
  
  templates:
    pagination: '''
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

  paginate: (event) ->
    event.preventDefault()
    event.stopPropagation()
    delta = if ($(event.target).data('action') is "previous") then -30 else 30
    @startDate.addWeeks(delta)
    StaffPlan.Dispatcher.trigger "date:changed"
      begin: @startDate.getTime()
      count: 30
 
  initialize: ->
    @users = @options.users
    @startDate = new XDate()
      
  render: ->
    @$el.empty()
    fragment = document.createDocumentFragment()
    @$el.append Handlebars.compile @templates.pagination
    
    @users.each (user) =>
      view = new StaffPlan.Views.StaffPlans.ListItem
        model: user
        startDate: @startDate.getTime()
      fragment.appendChild view.render().el
    @$el.append $(fragment)
    @$el.append Handlebars.compile @templates.addStaff
    @$el.appendTo('section.main')
    
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    @numberOfBars = Math.round(chartContainerWidth / 40) - 2
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.getTime(), @startDate.getTime() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    @$el.find("#date-target").html dateRangeView.render().el
