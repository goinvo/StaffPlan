class window.StaffPlan.Models.Assignment extends Backbone.Model
  NAME: "assignment"
  initialize: ->
    weeks = _.map @get("work_weeks"), (week) ->
      new StaffPlan.Models.WorkWeek week
    @work_weeks = new StaffPlan.Collections.WorkWeeks weeks,
      parent: @
    
    # No need for this anymore
    @unset "work_weeks"
    
    # When an element is removed from a collection, a "remove" event is triggered
    @bind 'remove', () ->
      @destroy()
