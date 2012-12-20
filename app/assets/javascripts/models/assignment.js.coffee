class window.StaffPlan.Models.Assignment extends StaffPlan.Model
  initialize: ->
    @work_weeks = new StaffPlan.Collections.WorkWeeks @get("work_weeks"),
      parent: @
    
    @unset "work_weeks"
    
    @work_weeks.sort()
    
    # When an element is removed from a collection, a "remove" event is triggered
    @bind 'remove', () ->
      @destroy()
  
  client: ->
    StaffPlan.clients.get(@get('client_id'))
    
  toJSON: ->
    _.reduce ['user_id', 'project_id', 'archived', 'proposed'], (obj, prop) =>
      obj[prop] = @get(prop)
      obj
    , {}


  isDeletable: ->
    0 is @work_weeks.reduce (total, element) ->
      total += parseInt(element.get("actual_hours") or 0, 10) + parseInt(element.get("estimated_hours") or 0, 10)
      total
    , 0
