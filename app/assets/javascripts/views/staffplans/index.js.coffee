class window.StaffPlan.Views.StaffPlans.Index extends Support.CompositeView
  className: "list padding-top-120"

  # All event handlers are defined in app/assets/javascripts/mixins/events.js.coffee
  events:
    "click ul.dropdown-menu.sort-users li a": "sortUsers"
    "click button.btn-primary[data-filter]": "toggleFilter"

  leave: ->
    @off()
    @remove()

  initialize: ->
    _.extend @, StaffPlan.Mixins.Events.weeks
    _.extend @, StaffPlan.Mixins.Events.memberships
    _.extend @, StaffPlan.Mixins.Events.users
    
    # Makes it so that the render() call can only be 
    # called AT MOST once every 500ms during resize
    @debouncedRender = _.debounce(@render, 500)
    $(window).bind "resize", (event) =>
      @debouncedRender()
    
    # We show active users by default
    # TODO: Maybe make it so that the set of users defined by the
    # user's filter is shown by default instead
    localStorage.setItem("staffplanFilter", "active")
    @users = new StaffPlan.Collections.Users @options.users.active()

    m = moment()
    @startDate = m.utc().startOf('day').subtract('days', m.day() - 1).subtract('weeks', 1)
    
    # When the collection of users changes, we render the view 
    # again to reflect the change in the UI
    @users.bind "reset", (event) =>
      @render()

    key "left, right", (event) =>
      @dateChanged if event.keyIdentifier is "Left" then "previous" else "next"

    @on "date:changed", (message) =>
      @dateChanged(message.action)

    @on "membership:toggle", (message) =>
      @toggleMembership(message)
    
    @on "year:changed", (message) =>
      @yearChanged(parseInt(message.year, 10))

  leave: ->
    $('body div.highlighter').remove()
    Support.CompositeView.prototype.leave.call @
  render: ->
    @$el.html StaffPlan.Templates.StaffPlans.index.pagination
    # FIXME: This is ugly
    buttonText = if localStorage.getItem("staffplanFilter") is "active"
      "Show inactive"
    else
      "Show active"
    @$el.find("button.btn-primary").text(buttonText)
    
    # We don't show the select control if the work weeks only span over ONE year
    if StaffPlan.relevantYears.length > 2
      @yearFilter = new StaffPlan.Views.Shared.YearFilter
        years: StaffPlan.relevantYears
        parent: @
      @$el.find('div.date-paginator div.fixed-180').append @yearFilter.render().el

    # Show the collection of users with the associated information and charts 
    @users.each (user) =>
      view = new StaffPlan.Views.StaffPlans.ListItem
        model: user
        parent: @
        startDate: @startDate.valueOf()
      @appendChild view
    @$el.append StaffPlan.Templates.StaffPlans.index.addStaff
    
    @numberOfBars = Math.floor( ($('section.main').width() - 220) / 40 )
    
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    @renderChildInto dateRangeView, @$el.find("#date-target")
    
    # m = moment()
    # timestampAtBeginningOfWeek = m.utc().startOf('day').subtract('days', m.day() - 1)
    
    # _.delay () ->
    #   $("*[data-timestamp=\"#{timestampAtBeginningOfWeek}\"]").addClass("current-week-highlight")
    # , 100
    # Ugly hack, the offset of the current week, if any, is only available after page load i.e. when 
    # @$el has finally been inserted into the DOM
    # _.delay () ->
    #   currentWeek = $("span.week-number[data-timestamp=\"#{timestampAtBeginningOfWeek.valueOf()}\"]")
    #   if currentWeek.length > 0
    #     highlighterView = new StaffPlan.Views.Shared.Highlighter
    #       offset:
    #         left: currentWeek.offset().left
    #         top: 150 
    #       width: 35
    #       height: 1000 # FIXME This value should be computed
    #     if $('body div.highlighter').length is 0
    #       $('body').append highlighterView.render().el
    # , 100
    @
