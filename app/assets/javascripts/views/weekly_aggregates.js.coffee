class StaffPlan.Views.WeeklyAggregates extends Support.CompositeView
  initialize: ->
    @startDate = @options.startDate
    @collection = @options.collection
    @height = 75
    @barWidth = 35
    @chartWidth = @options.width
    @maxHeight = @options.maxHeight

  render: ->
    svg = d3.select(@el)
      .attr('width', @chartWidth)
      .attr('height', @height)

    # Scale all the heights so that we don't get overflow on the y-axis
    heightScale = d3.scale.linear()
      .domain([0, @maxHeight])
      .range([0, @height - 20])
    
    # The data we're visualizing
    data = @collection.map (aggregate) ->
      aggregate.getTotals()

    # The SVG itself contains a g to group all the elements
    # We might need that in the future if we want to apply transformations
    # to all bars
    weeks = svg.append("g")
      .attr("class", "weeks")
      .attr("transform", "translate(19, 0)")
    
    # Each bar is actually contained in a g itself
    # That g also contains the number of hours for the bar as text
    groups = weeks.selectAll(".bar")
      .data(data, (d) -> d.cid)
      .enter().append("g")
        .attr("class", "week")
        .attr("transform", (d, i) -> "translate(#{i * 39.72}, 0)")
        .attr("data-cweek", (d) -> d.cweek)
        .attr("data-year", (d) -> d.year)

    # The label for the bar (number of hours aggregated for a given week)
    groups.selectAll("text")
      .data (d) ->
        [d.total]
      .enter().append("text")
        .attr("text-anchor", "middle")
        .attr 'y', (d) =>
          @height - heightScale(d) - (if d is 0 then 0 else 10)
        .attr("font-family", "sans-serif")
        .attr("font-size", "11px")
        .attr("fill", "black")
        .text (d) ->
          d + ""

    # The bars themselves, data is split up between two objects so that each bar has its own set of data
    groups.selectAll("rect")
      .data (d) ->
        [{value: Math.max(d.total, 0), cssClass: d.cssClass}, {value: Math.max(d.proposed, 0), cssClass: "#{d.cssClass} proposed"}]
      .enter().append("rect")
        .attr("x", -@barWidth / 2)
        .attr("width", @barWidth)
        .attr "y", (d) =>
          @height - heightScale(d.value)
        .attr "height", (d) ->
          heightScale(d.value)
        .attr "class", (d) ->
          d.cssClass
    @
