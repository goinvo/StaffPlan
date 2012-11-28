StaffPlan.Mixins.Events =
  weeks:
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

    dateChanged: (action) ->
      if action is "previous"
        @startDate.subtract('weeks', @numberOfBars)
      else
        @startDate.add('weeks', @numberOfBars)
      @children.each (child) =>
        child.trigger "date:changed"
          begin: @startDate
          count: @numberOfBars
  memberships:
    toggleMembership: (message) ->
      user = @users.detect (user) -> user.id is message.userId
      user.membership.save
        archived: not user.membership.get(message.action)
      , success: (model, response) =>
          $(message.subview.el).slideUp 400, "linear", () ->
            $(@).remove()
      , error: (model, response) ->
          alert "FAIL"
