class window.StaffPlan.Views.StaffPlans.AssignmentTotals extends Backbone.View
  className: "grid-row-element fixed-60"
  tagName: "div"
    
  initialize: ->
    @assignment = @options.assignment
    @assignment.model.work_weeks.bind 'change', (ww) => @render()
    
  render: ->
    hours = _.reduce(@assignment.model.work_weeks.models, (memo, ww) ->
      memo.estimated += parseInt(ww.get('estimated_hours'), 10) || 0
      memo.actual += parseInt(ww.get('actual_hours'), 10) || 0
      memo
    , {estimated: 0, actual: 0})
    hours.delta = hours.estimated - hours.actual
    @$el.html StaffPlan.Templates.StaffPlans.assignment_totals
      hours: hours
    @