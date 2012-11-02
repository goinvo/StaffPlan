class StaffPlan.Views.WeeklyAggregates extends Support.CompositeView
  initialize: ->

    # NOTE: The models inside this collection shouldn't have to be massaged any further 
    # i.e. if some weeks are emtpy, the collection must contain dummy aggregates to reflect that
    @collection = @options.collection
    @height = 75
    @barWidth = 35
    @chartWidth = @options.width
    @maxHeight = @options.maxHeight
  render: ->
    # At this point we have an array of objects containing all the information we need to create the bar graph
    # d3 is bound to that data
    chart = d3.select(@el)
      # FIXME: Values are hardwired here
      .attr('width', @chartWidth)
      .attr('height', @height)
    
    heightScale = d3.scale.linear().domain([0, @maxHeight]).range([0, @height - 20])

    values = @collection.map (aggregate) ->
      estimated: aggregate.get("totals").estimated
      cid: aggregate.cid

    list = chart.selectAll('rect').data(values, (d) -> d.cid)

    list
      .attr('height', (d) -> heightScale(d.estimated))
      .attr('width', @barWidth)
      .attr('x', (d, i) -> i * 39.72)
      .attr('y', (d) => @height - heightScale(d.estimated))
    list.enter()
      .append('rect')
      .attr('height', (d) -> heightScale(d.estimated))
      .attr('width', @barWidth)
      .attr('x', (d, i) -> i * 39.72)
      .attr('y', (d) => @height - heightScale(d.estimated))
      .attr('class', 'bar')


    chart.selectAll("text")
			   .data(values, (d) -> d.cid)
			   .enter()
			   .append("text")
			   .text((d) -> d.estimated)
			   .attr("text-anchor", "middle")
         .attr('x', (d, i) -> i * 39.72 + 14)
         .attr('y', (d) => @height - heightScale(d.estimated) - 5)
			   .attr("font-family", "sans-serif")
			   .attr("font-size", "11px")
			   .attr("fill", "black")
    
    @
