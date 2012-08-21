class WorkWeek extends Backbone.Model
  
class WorkWeekList extends Backbone.Collection
  model: WorkWeek
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
  
  dateRangeMeta: ->
    @parent.dateRangeMeta()
  
  url: ->
    @parent.url() + "/work_weeks"

window.WorkWeek = WorkWeek
window.WorkWeekList = WorkWeekList
