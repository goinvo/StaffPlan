class window.StaffPlan.Views.Projects.Index extends Support.CompositeView
  className: "list padding-top-120"
  
  initialize: ->
    m = moment()
    @startDate = m.utc().startOf('day').subtract('days', m.day() - 1).subtract('weeks', 1)
    @collection.bind "remove", () =>
      @render()

    @debouncedRender = _.debounce(@render, 500)
    $(window).bind "resize", (event) =>
      @debouncedRender()

    @on "date:changed", (message) =>
      if message.action is "previous"
        @startDate.subtract('weeks', @numberOfBars)
      else
        @startDate.add('weeks', @numberOfBars)
      @children.each (child) =>
        child.trigger "date:changed"
          begin: @startDate
          count: @numberOfBars
  
  leave: ->
    @off()
    @remove()
  
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

    @$el.html StaffPlan.Templates.Projects.index.header

    @collection.each (project) =>
      view = new StaffPlan.Views.Projects.ListItem
        model: project
        start: @startDate
      @appendChild view
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    
    @renderChildInto dateRangeView, @$el.find("#date-target")
    @$el.append StaffPlan.Templates.Projects.index.actions.addProject
    @
