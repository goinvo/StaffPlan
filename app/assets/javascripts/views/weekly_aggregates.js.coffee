class StaffPlan.Views.WeeklyAggregates extends Support.CompositeView 
  tagName: "svg"
  
  initialize: ->
    @numberOfWeeks = @options.numberOfWeeks
    @cweek = @options.cweek
    @year = @options.year
    @render()
  render: ->
    
    startTime = new XDate().setWeek(@cweek, @year).getTime()
    endTime = new XDate().setWeek(@cweek, @year).addWeeks(@numberOfWeeks).getTime()
    
    data = @collection.filter (aggregate) ->
      beginningOfWeek = new XDate().setWeek(aggregate.cweek, aggregate.year).getTime()
      beginningOfWeek >= startTime and beginningOfWeek < endTime
    
    console.log data
    # At this point we have an array of objects containing all the information we need to create the bar graph
    # d3 is bound to that data

    chart = d3.select(@$el)
