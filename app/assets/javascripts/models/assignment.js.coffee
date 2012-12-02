class window.StaffPlan.Models.Assignment extends StaffPlan.Model
  initialize: ->
    @work_weeks = new StaffPlan.Collections.WorkWeeks @get("work_weeks"),
      parent: @
    
    @unset "work_weeks"
    
    @work_weeks.sort()
    
    # When an element is removed from a collection, a "remove" event is triggered
    @bind 'remove', () ->
      @destroy()
