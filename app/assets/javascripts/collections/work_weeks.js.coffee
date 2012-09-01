class window.StaffPlan.Collections.WorkWeeks extends Backbone.Collection
  model: window.StaffPlan.Models.WorkWeek
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
  
  dateRangeMeta: ->
    @parent.dateRangeMeta()
  
  url: ->
    @parent.url() + "/work_weeks"
