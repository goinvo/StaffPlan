class window.StaffPlan.Views.Projects.Index extends Support.CompositeView
  
  initialize: ->
    m = moment()
    @startDate = m.utc().startOf('day').subtract('days', m.day() - 1)
    @collection.bind "remove", () =>
      @render()

  leave: ->
    @off()
    @remove()
  templates:
    header: '''
      <div class="row-fluid date-paginator"> 
        <div class="span2">
          <a href="#" class="pagination" data-action=previous>Previous</a>
          <a href="#" class="pagination" data-action=next>Next</a>
        </div>
        <div id="date-target" class="span10">
        </div>
      </div>
      '''
    actions:
      addProject: '''
        <div class="row-fluid actions">
          <a href="/projects/new" class="btn btn-primary" data-action="new">
            <i class="icon-list icon-white"></i>
            Add project
          </a>
        </div>
        '''
  events:
    "click div.controls a[data-action=delete]": "deleteProject"
    "click div.date-paginator a.pagination": "paginate"

  paginate: (event) ->
    event.preventDefault()
    event.stopPropagation()
    if $(event.target).data('action') is "previous"
      @startDate.subtract('weeks', @numberOfBars)
    else
      @startDate.add('weeks', @numberOfBars)
    StaffPlan.Dispatcher.trigger "date:changed"
      begin: @startDate.valueOf()
      count: @numberOfBars

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
    fragment = document.createDocumentFragment()
    @$el.empty()
    
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    @numberOfBars = Math.round(chartContainerWidth / 40) - 2

    @$el.append Handlebars.compile @templates.header
    @collection.each (project) =>
      view = new StaffPlan.Views.Projects.ListItem
        model: project
        start: @startDate
      fragment.appendChild view.render().el
    @$el.append $(fragment)
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    
    @$el.find("#date-target").html dateRangeView.render().el
    @$el.append Handlebars.compile @templates.actions.addProject
    @$el.appendTo 'section.main'
    
    @
