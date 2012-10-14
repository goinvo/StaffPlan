class WorkWeek extends Backbone.Model
  inSelectedSubset: ->
    if Modernizr.localstorage and !!localStorage.getItem("yearFilter")
      if localStorage.getItem("yearFilter") is "0"
        true
      else
        @get('year') is parseInt(localStorage.getItem("yearFilter"), 10)
    else
      true

class WorkWeekList extends Backbone.Collection
  model: WorkWeek
  
  initialize: (models, attrs) ->
    _.extend @, models
    _.extend @, attrs
  
  dateRangeMeta: ->
    @parent.dateRangeMeta()
  
  selectedSubset: ->
    if Modernizr.localstorage and !!localStorage.getItem("yearFilter")
      if localStorage.getItem("yearFilter") is "0"
        @
      else
        @filter (ww) ->
          ww.get('year') is parseInt(localStorage.getItem("yearFilter"), 10)
    else
      @ # TODO: Maybe add the cookie handling here in case localStorage is not available 

  url: ->
    @parent.url() + "/work_weeks"

window.WorkWeek = WorkWeek
window.WorkWeekList = WorkWeekList
