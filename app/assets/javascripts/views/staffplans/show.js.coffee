class window.StaffPlan.Views.StaffPlans.Show extends window.StaffPlan.Views.Shared.DateDrivenView
  initialize: ->
    window.StaffPlan.Views.Shared.DateDrivenView.prototype.initialize.call(this)
    @$el.text('StaffPlan.Views.StaffPlans.Show')
    @render()
    
  render: ->
    @$el.appendTo('section.main .content')
    