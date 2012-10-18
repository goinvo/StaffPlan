class window.StaffPlan.Models.Assignment extends Backbone.Model
  initialize: ->
    @work_weeks = new StaffPlan.Collections.WorkWeeks @get( 'work_weeks' ),
      parent: @
    @work_weeks.sort()
    # FIXME: Maybe @unset 'work_weeks' at this point since it's been made into an association?
