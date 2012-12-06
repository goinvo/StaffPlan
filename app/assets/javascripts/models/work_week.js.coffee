class window.StaffPlan.Models.WorkWeek extends StaffPlan.Model
  getAssignment: ->
    @collection.parent
  
  pick: (attrs) ->
    _.reduce attrs, (memo, elem) =>
      if typeof this[elem] is "function"
        memo[elem] = this[elem].apply(@)
      else
        memo[elem] = @get elem
      memo
    , {}
    
  formatForTemplate: ->
    m = moment()
    timestampAtBeginningOfWeek = m.utc().startOf('day').subtract('days', m.day() - 1).valueOf()
    _.extend (@pick ["beginning_of_week"]),
      proposed: if @get("proposed") then "true" else "false"
      estimated_hours: @get("estimated_hours") or 0
      actual_hours: @get("actual_hours") or 0
      hasPassedOrIsCurrent: !@inFuture()
      highlight: parseInt(@get("beginning_of_week"), 10) is timestampAtBeginningOfWeek
      cid: @cid

  inFuture: ->
    @get("beginning_of_week") > moment().utc().valueOf()
