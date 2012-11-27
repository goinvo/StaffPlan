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


  getWorkWeeks: ->
    year = parseInt(localStorage.getItem("yearFilter"), 10)
    if year isnt 0
      new StaffPlan.Collections.WorkWeeks @work_weeks.select (week) ->
        moment(week.get("beginning_of_week")).year() is parseInt(year, 10)
    else
      @work_weeks
