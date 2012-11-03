class StaffPlan.Views.WeeklyAggregates extends Support.CompositeView
  initialize: ->
    @startDate = @options.startDate
    @collection = @options.collection
    @height = 75
    @barWidth = 35
    @chartWidth = @options.width
    @maxHeight = @options.maxHeight

  render: ->
    chart = d3.select(@el)
      .attr('width', @chartWidth)
      .attr('height', @height)
     
    heightScale = d3.scale.linear().domain([0, @maxHeight]).range([0, @height - 20])
    values = @collection.map (aggregate) ->
      estimated: aggregate.get("totals").estimated
      proposed: aggregate.get("totals").proposedEstimated
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
      .attr('fill', '#5E9B69')

    chart.selectAll("text")
			   .data(values, (d) -> d.cid)
			   .enter()
			   .append("text")
         .text((d) -> d.estimated)
			   .attr("text-anchor", "middle")
         .attr('x', (d, i) -> i * 39.72 + 16)
         .attr('y', (d) => @height - heightScale(d.estimated) - 5)
			   .attr("font-family", "sans-serif")
			   .attr("font-size", "11px")
			   .attr("fill", "black")
    
    @
