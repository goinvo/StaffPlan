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
        <h3>List of Projects</h3>
      </div>
      <div id="pagination">
        <a class="pagination" data-action=previous href="#">Previous</a>
        <a class="pagination" data-action=next href="#">Next</a>
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
