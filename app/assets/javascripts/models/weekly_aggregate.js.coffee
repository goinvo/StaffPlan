class window.StaffPlan.Models.WeeklyAggregate extends StaffPlan.Model
  initialize: (options) ->
    @set "cweek",         options.cweek
    @set "year",          options.year
    @set "timestamp",     new XDate().setWeek(options.cweek, options.year).getTime()
    @set "totals",
      proposed:  if options.proposed then (parseInt( options.estimated_hours, 10) || 0) else 0
      estimated:          parseInt(options.estimated_hours, 10) || 0
      actual:             parseInt(options.actual_hours, 10) || 0
    
    @unset "actual_hours"
    @unset "proposed"
    @unset "estimated_hours"

  update: (week) ->
    @get("totals").estimated          += (parseInt( week.estimated_hours, 10) || 0)
    @get("totals").actual             += (parseInt( week.actual_hours, 10) || 0)
    @get("totals").proposed  += if week.proposed then (parseInt( week.estimated_hours, 10) || 0) else 0
  
  getTotals: ->
    date = new XDate()
    totals = @get("totals")
    timestampAtBeginningOfWeek = date.setWeek(date.getWeek(), date.getFullYear()).getTime()
    totals = if @get("timestamp") > timestampAtBeginningOfWeek # The aggregate is for a future date, take the estimates
      total: totals.estimated
      proposed: totals.proposed
      cssClass: "estimates"
    else # The aggregate is either for the current week or the past, take the actuals if any or fall back to estimates
      if (totals.actual is 0) or (totals.actual is undefined)
        total: totals.estimated
        proposed: totals.proposed
        cssClass: "estimates"
      else
        total: totals.actual
        proposed: 0
        cssClass: "actuals"
    _.extend totals,
      cweek: @get "cweek"
      year: @get "year"
      cid: @cid

  applyDelta: (delta) ->
    _.each ["estimated", "actual", "proposedActual", "proposedEstimated"] (attr) ->
      @get("totals")[attr] += delta[attr] || 0
