class window.StaffPlan.Models.Assignment extends Backbone.Model
  NAME: "assignment"
  initialize: ->
    @work_weeks = new StaffPlan.Collections.WorkWeeks @get( 'work_weeks' ),
      parent: @
    @work_weeks.sort()

    # When an element is removed from a collection, a "remove" event is triggered
    @bind 'remove', () ->
      @destroy()
