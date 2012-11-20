class window.StaffPlan.Views.Projects.Index extends Support.CompositeView
  
  initialize: ->
    m = moment()
    @startDate = m.utc().startOf('day').subtract('days', m.day() - 1)
    @collection.bind "remove", () =>
      @render()
    @addProjectTemplate = Handlebars.compile @templates.actions.addProject
    @headerTemplate = Handlebars.compile @templates.header

    @debouncedRender = _.debounce(@render, 500)
    $(window).bind "resize", (event) =>
      @debouncedRender()

    @on "date:changed", (message) =>
      if message.action is "previous"
        @startDate.subtract('weeks', @numberOfBars)
      else
        @startDate.add('weeks', @numberOfBars)
      # We must use Backbone.Support's conventions of appendChild and renderChildInto
      # so that the @children array of children views is available here
      @children.each (child) =>
        child.trigger "date:changed"
          begin: @startDate
          count: @numberOfBars

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
    chartContainerWidth = Math.round(($("body").width() - 2 * 40) * 10 / 12)
    @numberOfBars = Math.round(chartContainerWidth / 40) - 2

    @$el.html @headerTemplate

    @collection.each (project) =>
      view = new StaffPlan.Views.Projects.ListItem
        model: project
        start: @startDate
      @appendChild view
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    
    @renderChildInto dateRangeView, @$el.find("#date-target")
    @$el.append @addProjectTemplate
    @
