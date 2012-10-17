class StaffPlan.Views.WeeklyAggregates extends Support.CompositeView 
  initialize: ->
    @numberOfWeeks = @options.numberOfWeeks
    @cweek = @options.cweek
    @year = @options.year
    @offsetLeft = @options.offsetLeft
    @render()
  render: ->
    
    startTime = new XDate().setWeek(@cweek, @year).getTime()
    endTime = new XDate().setWeek(@cweek, @year).addWeeks(@numberOfWeeks).getTime()
    
    dataset = @collection.filter (aggregate) ->
      beginningOfWeek = new XDate().setWeek(aggregate.cweek, aggregate.year).getTime()
      beginningOfWeek >= startTime and beginningOfWeek < endTime
    
    # At this point we have an array of objects containing all the information we need to create the bar graph
    # d3 is bound to that data
    # @el.empty()
    chart = d3.select(@el)
      .attr('width', 1400)
      .attr('height', 75)
      .attr('x', @offsetLeft)
    
    values = dataset.map (aggregate) ->
      estimated: aggregate.values.estimated
      cid: aggregate.cid

    console.log values
    list = chart.selectAll('rect').data(values, (d) -> d.cid)

    list
      .attr('height', (d) -> d.estimated)
      .attr('width', 34)
      .attr('x', (d, i) -> i * 40)
      .attr('y', (d) -> 75 - d.estimated)
    list.enter()
      .append('rect')
      .attr('height', (d) -> d.estimated)
      .attr('width', 34)
      .attr('x', (d, i) -> i * 40)
      .attr('y', (d) -> 75 - d.estimated )
      .attr('class', 'bar')
