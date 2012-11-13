class window.StaffPlan.Models.WorkWeek extends StaffPlan.Model
  
  pick: (attrs) ->
    _.reduce attrs, (memo, elem) =>
      if typeof this[elem] is "function"
        memo[elem] = this[elem].apply(@)
      else
        memo[elem] = @get elem
      memo
    , {}
    
  formatForTemplate: -> _.extend (@pick ["beginning_of_week"]),
    proposed: if @get("proposed") then "true" else "false"
    estimated_hours: @get("estimated_hours") or 0
    actual_hours: @get("actual_hours") or 0
    hasPassedOrIsCurrent: not @inFuture()
    cid: @cid


  inFuture: ->
    @get("beginning_of_week") > moment().utc().startOf('week').startOf('day')
