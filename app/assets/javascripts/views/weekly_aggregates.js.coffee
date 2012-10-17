class StaffPlan.Views.WeeklyAggregates extends Backbone.View
  initialize: ->
     
  tagName: "svg"

  render: ->
    @$el.appendTo "section.main div.content"
    # TODO: Ideally, we render once and then we just call a 
    # refresh function when the underlying data changes
