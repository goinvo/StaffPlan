class window.StaffPlan.Models.Assignment extends Backbone.Model
  initialize: ->
    @work_weeks = new StaffPlan.Collections.WorkWeeks @get( 'work_weeks' ),
      parent: @
    @work_weeks.sort()
    # Once the association to the work weeks has been established, no need to keep duplicates??
    @unset( 'work_weeks' )
