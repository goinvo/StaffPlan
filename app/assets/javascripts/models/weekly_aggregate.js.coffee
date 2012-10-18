class window.StaffPlan.Models.WeeklyAggregate extends Backbone.Model
  initialize: (options) =>
    @cweek = options.cweek
    @year = options.year
    @totals =
      proposed: 0
      estimated: 0
      actual: 0
    @updateTotals(options)
    
    
  updateTotals: (week) ->
    # Just in case we're trying to update an aggregate with a work_week from another week
    unless (week.year isnt @year) or (week.cweek isnt @cweek)
      @totals.estimated    += parseInt(week.estimated_hours, 10) || 0
      @totals.actual       += parseInt(week.actual_hours, 10) || 0
      @totals.proposed     += (parseInt(week.estimated_hours, 10) || 0) if week.proposed
