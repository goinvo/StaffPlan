class window.StaffPlan.Models.WeeklyAggregate extends StaffPlan.Model
  initialize: (options) =>
    @set "cweek",         options.cweek
    @set "year",          options.year
    @set "timestamp",     new XDate().setWeek(options.cweek, options.year).getTime()
    @set "totals",
      proposedActual:     if options.proposed then (parseInt( options.actual_hours, 10) || 0) else 0
      proposedEstimated:  if options.proposed then (parseInt( options.estimated_hours, 10) || 0) else 0
      estimated:          parseInt(options.estimated_hours, 10) || 0
      actual:             parseInt(options.actual_hours, 10) || 0
    
    @unset "actual_hours"
    @unset "proposed"
    @unset "estimated_hours"

  update: (week) ->
    @get("totals").estimated          += (parseInt( week.estimated_hours, 10) || 0)
    @get("totals").actual             += (parseInt( week.actual_hours, 10) || 0)
    @get("totals").proposedActual     += if week.proposed then (parseInt( week.actual_hours, 10) || 0) else 0
    @get("totals").proposedEstimated  += if week.proposed then (parseInt( week.estimated_hours, 10) || 0) else 0
  
  applyDelta: (delta) ->
    _.each ["estimated", "actual", "proposedActual", "proposedEstimated"] (attr) ->
      @get("totals")[attr] += delta[attr] || 0
