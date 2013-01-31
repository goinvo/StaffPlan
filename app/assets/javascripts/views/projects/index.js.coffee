class window.StaffPlan.Views.Projects.Index extends StaffPlan.View
  className: "list projects-index short"
  
  initialize: ->
    _.extend @, StaffPlan.Mixins.Events.weeks
    # FIXME: Only working version I know as of now
    if window.location.hash.length
      @startDate = moment(parseInt(window.location.hash.slice(1).split("=")[1], 10))
    else
      m = moment()
      @startDate = m.utc().startOf('day').subtract('days', m.day() - 1).subtract('weeks', 1)
    @collection.bind "remove", () =>
      @render()

    key "left, right", (event) =>
      @dateChanged if event.keyIdentifier.toLowerCase() is "left" then "previous" else "next"

    @debouncedRender = _.debounce(@render, 500)
    $(window).bind "resize", (event) =>
      @debouncedRender()

    @on "year:changed", (message) =>
      @yearChanged(parseInt(message.year, 10))
    
    @on "date:changed", (message) =>
      @dateChanged(message.action)
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
    super
    
    @numberOfBars = Math.floor( ($('body').width() - 320) / 40 )

    @$el.find('header').append StaffPlan.Templates.Projects.index.header

    if StaffPlan.relevantYears.length > 2
      @yearFilter = new StaffPlan.Views.Shared.YearFilter
        years: StaffPlan.relevantYears
        parent: @
      @$el.find('header .inner ul:first').append @yearFilter.render().el
      
    @collection.each (project) =>
      view = new StaffPlan.Views.Projects.ListItem
        model: project
        start: @startDate
      @appendChildTo view, @$el.find('section.main')
      
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    
    @renderChildInto dateRangeView, @$el.find("#date-target")
    
    @$el.find('section.main').append StaffPlan.Templates.Projects.index.actions.addProject

    @
