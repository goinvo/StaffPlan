class window.StaffPlan.Views.StaffPlans.AssignmentTotals extends Support.CompositeView
  className: "grid-row-element fixed-60"
  tagName: "div"
    
  initialize: ->
    @model.work_weeks.bind 'change', (ww) =>
      @render()
    
  render: ->
    hours = _.reduce(@model.work_weeks.models, (memo, ww) ->
      
      unless ww.inFuture()
        memo.currentAndPastActual += parseInt(ww.get('estimated_hours', 10) || 0)
        memo.currentAndPastEstimated += parseInt(ww.get('actual_hours', 10) || 0)
        
      memo.estimated += parseInt(ww.get('estimated_hours'), 10) || 0
      memo.actual += parseInt(ww.get('actual_hours'), 10) || 0
      memo
    , {estimated: 0, actual: 0, currentAndPastEstimated: 0, currentAndPastActual: 0})
    
    hours.delta = hours.currentAndPastActual - hours.currentAndPastEstimated
    
    @$el.html HandlebarsTemplates["staffplans/assignment/totals"]
      hours: hours
    @
