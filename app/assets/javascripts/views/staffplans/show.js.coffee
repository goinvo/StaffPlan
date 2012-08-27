class window.StaffPlan.Views.StaffPlans.Show extends window.StaffPlan.Views.Shared.DateDrivenView
  initialize: ->
    window.StaffPlan.Views.Shared.DateDrivenView.prototype.initialize.call(this)
    @render()
    
  render: ->
    @$el.text('sup').appendTo('section.main .content')