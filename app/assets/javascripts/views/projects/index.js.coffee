class window.StaffPlan.Views.Projects.Index extends Support.CompositeView
  tagName: 'ul'
  className: 'project-list slick'
  
  initialize: ->
    @startDate = new XDate()
    @collection.bind "remove", () =>
      @render()

    @projectListItemViews = @collection.reduce (memo, project) =>
      # For each element in the collection, create a subview
      memo.push new window.StaffPlan.Views.Projects.ListItem
        model: project
        startDate: @startDate
      memo
    , []

  templates:
    header: '''
      <div>
        <li class="row-fluid">
          <div class="span2">
            List of Projects
          </div>
          <div id="pagination" class="span10" style="border-left: 2px solid black">
            <a class="pagination" data-action=previous href="#"><--</a>
            <a class="pagination" data-action=next href="#">--></a>
          </div>
        </li>
      </div>
      '''
    actions:
      addProject: '''
        <div class="actions">
          <a href="/projects/new" class="btn btn-primary" data-action="new">
            <i class="icon-list icon-white"></i>
            Add project
          </a>
        </div>
        '''
  events:
    "click div.controls a[data-action=delete]": "deleteProject"
    "click div#pagination a.pagination": "paginate"

  paginate: (event) ->
    event.preventDefault()
    event.stopPropagation()
    delta = if ($(event.target).data('action') is "previous") then -30 else 30
    @startDate.addWeeks(delta)
    # window.dateRange = _.range(@startDate.getTime(), @startDate.clone().addWeeks(30).getTime(), 7 * 86400 * 1000)
    # date = new XDate()
    # _.map dateRange, (timestamp) ->
    #   d = date.setTime(timestamp)
    #   d.setWeek(d.getWeek(), d.getFullYear())
    #   if (a = Math.ceil(d.getDate() / 7)) is 1
    #     "" + d.toString("MMM") + "/W" + a;
    #   else
    #     "W" + a;
    
    StaffPlan.Dispatcher.trigger "date:changed"
      date: @startDate 

  deleteProject: ->
    event.preventDefault()
    event.stopPropagation()
    projectId = $(event.target).data("project-id")
    deleteView = new window.StaffPlan.Views.Shared.DeleteModal
      model: @collection.get(projectId)
      collection: @collection
    @$el.append deleteView.render().el
    $('#delete_modal').modal
      show: true
      keyboard: true
      backdrop: 'static'

  render: ->
    @$el.empty()
    @$el.append Handlebars.compile @templates.header
    _.each @projectListItemViews, (view) =>
      @$el.append view.render().el
    
    @$el.append Handlebars.compile @templates.actions.addProject
    @$el.appendTo 'section.main'

    @
