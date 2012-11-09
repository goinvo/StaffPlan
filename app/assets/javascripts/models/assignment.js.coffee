class window.StaffPlan.Models.Assignment extends StaffPlan.Model
  NAME: "assignment"
  initialize: ->
    @work_weeks = new StaffPlan.Collections.WorkWeeks @get("work_weeks"),
      parent: @
    @unset "work_weeks"
    
    @work_weeks.sort()
    
    # When an element is removed from a collection, a "remove" event is triggered
    @bind 'remove', () ->
      @destroy()

   getHoursForPeriod: (begin, end) ->
     date = new XDate()
     # TODO: Port code to fill the gaps from the weekly aggregates
     @work_weeks.select (week) ->
      time = date.setWeek(week.get("cweek"), week.get("year")).getTime()
      time > begin and time < end
