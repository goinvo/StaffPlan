class WorkWeek extends Backbone.Model
  initialize: ->
    
  urlRoot: "/work_weeks"
  
class WorkWeekList extends Backbone.Collection
  model: WorkWeek
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
  
  url: ->
    @parent.url() + "/WorkWeek"

window.WorkWeek = WorkWeek
window.WorkWeekList = WorkWeekList