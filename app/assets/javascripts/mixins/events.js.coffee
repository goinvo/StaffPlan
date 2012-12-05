StaffPlan.Mixins.Events =
  weeks:

    # Called when the user filters the data by year using the select widget
    # =====================================================================
    yearChanged: (year) ->
      unless _.include StaffPlan.relevantYears, year
        # We remove the cached property used to access filtered weeks (speeds up rendering)
        StaffPlan.assignments.each (assignment) ->
          assignment.unset "filteredWeeks"
      else
        StaffPlan.assignments.each (assignment) ->
          # Cache the filtered weeks as a prop of the assignment to speed up rendering
          assignment.set "filteredWeeks", assignment.work_weeks.select (week) ->
            moment(week.get("beginning_of_week")).year() is year
      @render()
    
    # Called when the user paginates in any date-driven view
    # ======================================================
    dateChanged: (action) ->
      if action is "previous"
        @startDate.subtract('weeks', @numberOfBars)
      else
        @startDate.add('weeks', @numberOfBars)
        
      timestampRange = _.range(@startDate.valueOf(), @startDate.valueOf() + @numberOfBars * 7 * 86400 * 1000, 7 * 86400 * 1000)
      m = moment()
      timestampAtBeginningOfCurrentWeek = m.utc().startOf('day').subtract('days', m.day() - 1).valueOf()
      if _.include timestampRange, timestampAtBeginningOfCurrentWeek # We need to highlight
        _.delay () ->
          currentWeek = $("span.week-number[data-timestamp=\"#{timestampAtBeginningOfCurrentWeek.valueOf()}\"]")
          if currentWeek.length > 0
            highlighterView = new StaffPlan.Views.Shared.Highlighter
              offset: currentWeek.offset()
              width: 35
              height: 1000 # FIXME This value should be computed
            $('body').append highlighterView.render().el
        , 100
      else
        $('body div.highlighter').remove()

      @children.each (child) =>
        child.trigger "date:changed"
          begin: @startDate
          count: @numberOfBars
    
    onWindowResized: (action) ->
      @children.each (child) ->
        child.trigger "window:resized"
        
  memberships:

    # Called when the user modifies the "disabled" or "archived" bit on a membership
    # (i.e. the user is disabled or archived for his current company)
    # ==============================================================================
    toggleMembership: (message) ->
      user = @users.detect (user) -> user.id is message.userId
      user.membership.save
        archived: not user.membership.get(message.action)
      , success: (model, response) =>
          $(message.subview.el).slideUp 400, "linear", () ->
            $(@).remove()
      , error: (model, response) ->
          alert "FAIL"
  users:
    # Called when the user toggles the active/inactive filter used to display 
    # active (i.e. non-archived or non-disabled) users or inactive ones.
    # =======================================================================
    toggleFilter: (event) ->
      filter = localStorage.getItem("staffplanFilter")
      models = if filter is "inactive" then StaffPlan.users.active() else StaffPlan.users.inactive()
      localStorage.setItem("staffplanFilter", if filter is "active" then "inactive" else "active")
      @users.reset models

    # Called when the user sorts the users by either workload or name on the staffplans page
    # ======================================================================================
    sortUsers: (event) ->
      event.stopPropagation()
      event.preventDefault()
      target = $(event.target)
      [criterion, order] = [target.data('criterion'), target.data('order')]
      sorted = switch criterion
        when "workload"
          @users.sortBy (user) -> user.workload()
        when "name"
          @users.sortBy (user) -> user.get("last_name")
      @users.reset (if order is "asc" then sorted else sorted.reverse())
