class window.StaffPlan.Views.StaffPlans.Index extends Support.CompositeView
  tagName: 'ul'
  className: 'staffplan-list slick'
  
  templates:
    pagination: '''
    <div id="pagination">
      <a class="pagination" data-action=previous href="#">Previous</a>
      <a class="pagination" data-action=next href="#">Next</a>
    </div>
    '''
    addStaff: '''
    <div class="actions">
      <a class="btn btn-primary" href="/users/new">Add Staff</a>
    </div>
    '''
  events:
    "click div#pagination a.pagination": "paginate"

  paginate: (event) ->
    event.preventDefault()
    event.stopPropagation()
    delta = if ($(event.target).data('action') is "previous") then -30 else 30
    @startDate.addWeeks(delta)
    @render()
 
  initialize: ->
    @users = @options.users
    @startDate = new XDate()
      
  render: ->
    @$el.empty()
    @$el.append Handlebars.compile @templates.pagination
    @users.each (user) =>
      view = new StaffPlan.Views.StaffPlans.ListItem
        model: user
        startDate: @startDate
      @$el.append view.render().el

    @$el.append Handlebars.compile @templates.addStaff
    @$el.appendTo('section.main')
    
  leave: ->
    @off()
    @remove()
