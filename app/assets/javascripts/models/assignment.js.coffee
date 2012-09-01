class window.StaffPlan.Models.Assignment extends Backbone.Model
  initialize: ->
    @work_weeks = new window.StaffPlan.Collections.WorkWeeks @get( 'work_weeks' ),
      parent: @