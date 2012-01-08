class WorkWeek extends Backbone.Model
  
  urlRoot: "/work_weeks"
  
class WorkWeekList extends Backbone.Collection
  model: WorkWeek
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
    
    @view = new WorkWeekListView
      model: @
    
    @bind 'change:actual_hours', ->
      @view.updateTotals()

    @bind 'change:estimated_hours', ->
      @view.updateTotals()
  
  dateRangeMeta: ->
    @parent.dateRangeMeta()
  
  url: ->
    @parent.url() + "/work_weeks"

window.WorkWeek = WorkWeek
window.WorkWeekList = WorkWeekList