class StaffPlan.Collections.WeeklyAggregates extends Backbone.Collection
  
  model: StaffPlan.Models.WeeklyAggregate
 
  initialize: (models) ->

  comparator: (first, second) ->
    firstYear = first['year']
    secondYear = second['year']
    
    if firstYear == secondYear
      if first['cweek'] < second['cweek'] then -1 else 1
    else
      if firstYear < secondYear then -1 else 1

  # TODO: This collection has a view now...
  # The view will have a render function that takes a collection of aggregates, a starting date and a size
  # It will expose a subset of the collection to d3 (the subset defined by start and size)
  # which will in turn update the graph accordingly
