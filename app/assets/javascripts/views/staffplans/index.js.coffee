class window.StaffPlan.Views.StaffPlans.Index extends Support.CompositeView
  templates:
    staffplanList: '''
    <ul class="user-list unstyled slick">  
    </ul>
    <div class="actions">
      <a class="btn btn-primary" href="/users/new">Add Staff</a>
    </div>
    '''
  
  initialize: ->
    @users = @options.users
    @staffplanList = Handlebars.compile @templates.staffplanList
    @startDate = new XDate()
      
    @render()
    
  render: ->
    @$el.empty()
    @$el.html @staffplanList
    @users.each (user) =>
      view = new StaffPlan.Views.StaffPlans.ListItem
        model: user
        startDate: @startDate
      @$el.find("ul.slick").append view.render().el

    @$el.appendTo('section.main')
    
  leave: ->
    @off()
    @remove()
