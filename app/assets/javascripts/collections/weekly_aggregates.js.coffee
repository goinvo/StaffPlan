class window.StaffPlan.Collections.WeeklyAggregates extends Backbone.Collection
  
  model: window.StaffPlan.Models.WeeklyAggregate
 
  initialize: (models, parent) ->
     
    @parent = parent
    
  populate: () ->
    @parent.assignments.each (assignment) =>
      assignment.work_weeks.each (week) =>
        # FIXME: Refactor with a findOrCreate that encapsulates all this non-sense.
        aggregate = @detect (agg) ->
          ( agg.year is parseInt week.get "year" ) and ( agg.cweek is parseInt week.get "cweek" )
        if aggregate?
          aggregate.updateTotals week.toJSON()
        else
          foobar = @add week.toJSON()
          # TODO: I don't know how to reference the newly added model here
          # I need it to do a week.set("aggregator", newlyAddedWeeklyAggregate)
    @

  comparator: (first, second) ->
    firstYear = first.year
    secondYear = second.year
    
    if firstYear == secondYear
      if first.cweek < second.cweek then -1 else 1
    else
      if firstYear < secondYear then -1 else 1
