class window.StaffPlan.Views.StaffPlans.Index extends Support.CompositeView
  tagName: 'ul'
  className: 'staffplan-list slick'
  
  templates:
    addStaff: '''
    <div class="actions">
      <a class="btn btn-primary" href="/users/new">Add Staff</a>
    </div>
    '''
  
  initialize: ->
    @users = @options.users
    @startDate = new XDate()
      
  render: ->
    @$el.empty()
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
