class window.StaffPlan.Views.StaffPlans.Index extends StaffPlan.View

  attributes:
    id:    "staffplan-index"
    class: "short"

  # All event handlers are defined in app/assets/javascripts/mixins/events.js.coffee
  events:
    "click .date-paginator .btn-group a": "sortUsers"
    "click button.btn-primary[data-filter]": "toggleFilter"

  leave: ->
    @off()
    @remove()

  initialize: ->
    _.extend @, StaffPlan.Mixins.Events.weeks
    _.extend @, StaffPlan.Mixins.Events.memberships
    _.extend @, StaffPlan.Mixins.Events.users

    @sort =
      field: "workload"
      order: "asc"

    # Makes it so that the render() call can only be
    # called AT MOST once every 500ms during resize
    @debouncedRender = _.debounce =>
      @calculateNumberOfBars()
      @children.each (view) -> view.render()
      @renderDates()
    , 200
    
    $(window).bind "resize", (event) => @render()

    # We show active users by default
    # TODO: Maybe make it so that the set of users defined by the
    # user's filter is shown by default instead
    localStorage.setItem("staffplanFilter", "active")
    @users = new StaffPlan.Collections.Users @options.users.active()
    @users.reset @users.sortBy (user) -> user.workload()

    m = moment()
    @startDate = m.utc().startOf('day').subtract('days', m.day() - 1).subtract('weeks', 1)

    # When the collection of users changes, we render the view
    # again to reflect the change in the UI
    @users.bind "reset", (event) => @render()

    key "left, right", (event) =>
      @dateChanged if event.keyIdentifier.toLowerCase() is "left" then "previous" else "next"

    @on "date:changed", (message) => @dateChanged(message.action)
    @on "membership:toggle", (message) => @toggleMembership(message)
    @on "year:changed", (message) => @yearChanged(parseInt(message.year, 10))
  
  calculateNumberOfBars: ->
    @numberOfBars = Math.floor( ($('body').width() - 280) / 40 )
  
  renderUsers: ->
    # Show the collection of users with the associated information and charts
    $list = @$main.find(".list")

    @users.each (user) =>
      view = new StaffPlan.Views.StaffPlans.ListItem
        model: user
        parent: @
        startDate: @startDate.valueOf()
      @appendChildTo view, $list
  
  renderDates: ->
    dateRangeView = new StaffPlan.Views.DateRangeView
      collection: _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
    @renderChildInto dateRangeView, @$el.find("#date-target")
  
  renderFYSelect: ->
    # We don't show the select control if the work weeks only span over ONE year
    if StaffPlan.relevantYears.length > 2
      @yearFilter = new StaffPlan.Views.Shared.YearFilter
        years: StaffPlan.relevantYears
        parent: @
      @$el.find('header .inner ul:first').append @yearFilter.render().el
    
  render: ->
    if @rendered
      @debouncedRender()
    else
      super

      @$main ||= @$el.find("section.main")
      @$main.append("<div class='list' />")

      # this @sort business obviously sucks. This should leverage the location.hash and hashchange.
      $lower = jQuery('<div class="lower" />')
      @$el.find('header').append $lower
      $lower.append StaffPlan.Templates.StaffPlans.index.pagination
        sortASC: @sort.order == "asc"
        byWorkload: @sort.field == "workload"

      # FIXME: This is ugly
      buttonText = if localStorage.getItem("staffplanFilter") is "active"
        "Show inactive"
      else
        "Show active"

      @$el.find("button.btn-primary").text(buttonText)

      @calculateNumberOfBars()
    
      @renderFYSelect()
    
      @renderUsers()

      @$main.append StaffPlan.Templates.StaffPlans.index.addStaff

      @renderDates()
      
      @rendered = true
      
    @

  sortUsers: (event) ->
    event.stopPropagation()
    event.preventDefault()

    $currentTarget = $(event.currentTarget)
    key = $currentTarget.data().key
    value = $currentTarget.data().value
    @sort[ key ] = value

    sorted = switch @sort.field
      when "workload"
        @users.sortBy (user) -> user.workload()
      when "name"
        @users.sortBy (user) -> user.get("first_name")

    @users.reset (if @sort.order is "asc" then sorted else sorted.reverse())

