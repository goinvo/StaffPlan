class StaffPlan.Views.WeeklyAggregates extends Support.CompositeView
  WEEK_IN_MILLISECONDS = 7 * 86400 * 1000
  
  initialize: ->
    @model = @options.model
    
    @begin = @options.begin.valueOf()
    @count = @options.count
    @height = 75 || @options.height
    @barWidth = 35 || @options.barWidth
    
    @chartWidth = @count * 40

    @maxHeight = @options.maxHeight

    StaffPlan.Dispatcher.on "date:changed", (message) =>
      @begin = message.begin
      @count = message.count
      @redrawChart()

    StaffPlan.Dispatcher.on "week:updated", (message) =>
      # FIXME: Maybe make a function out of this that we can reuse in the getData function (just take timestamp range
      # and map)
      weeks = _.flatten @model.getAssignments().map (assignment) ->
        assignment.work_weeks.detect (week) ->
          parseInt(week.get("beginning_of_week"), 10) is parseInt(message.timestamp, 10)
      aggregate = _.reduce weeks, (memo, week) =>
        memo['estimated_hours'] += (parseInt(week.get("estimated_hours"), 10) or 0)
        memo['actual_hours'] += (parseInt(week.get("actual_hours"), 10) or 0)
        memo['proposed'] += if week["proposed"] then (parseInt(week.get("estimated_hours"), 10) or 0) else 0
        memo
      , {estimated_hours: 0, actual_hours: 0, proposed: 0, beginning_of_week: message.timestamp}
      opts = if aggregate.actual_hours isnt 0
        total: aggregate.actual_hours
        proposed: 0
        cssClass: "actuals"
        beginning_of_week: aggregate.beginning_of_week
      else
        total: aggregate.estimated_hours
        proposed: aggregate.proposed
        cssClass: "estimates"
        beginning_of_week: aggregate.beginning_of_week
      
      @redrawBar opts
  leave: ->
    @off()
    @remove()
  # We need to retrieve the aggregates for the given date range
  getData: ->
      # date = moment().utc()
      range = _.range(@begin, @begin + @count * WEEK_IN_MILLISECONDS, WEEK_IN_MILLISECONDS)
      aggs = _.reduce range, (memo, timestamp) ->
        memo["#{timestamp}"] =
          beginning_of_week: timestamp
          proposed: 0
          actual_hours: 0
          estimated_hours: 0
        memo
      , {}
      weeks = _.flatten @model.getAssignments().map (assignment) =>
        assignment.work_weeks.between(@begin, @begin + @count * WEEK_IN_MILLISECONDS)
      
      aggregates = _.reduce weeks, (memo, week) =>
        obj = memo["#{week['beginning_of_week']}"]
        obj['estimated_hours'] += (week["estimated_hours"] or 0)
        obj['actual_hours'] += (week["actual_hours"] or 0)
        obj['proposed'] += if week["proposed"] then (week["estimated_hours"] or 0) else 0
        memo
      , aggs
      
      _.map aggregates, (aggregate) ->
        if aggregate.actual_hours isnt 0
          total: aggregate.actual_hours
          proposed: 0
          cssClass: "actuals"
          beginning_of_week: aggregate.beginning_of_week
        else
          total: aggregate.estimated_hours
          proposed: aggregate.proposed
          cssClass: "estimates"
          beginning_of_week: aggregate.beginning_of_week

  render: ->
    @$el.empty()
    svg = d3.select(@el)
      .attr('width', @chartWidth)
      .attr('height', @height)

    # Scale all the heights so that we don't get overflow on the y-axis
    @heightScale = d3.scale.linear()
      .domain([0, @maxHeight])
      .range([0, @height - 20])
    
    # The SVG itself contains a g to group all the elements
    # We might need that in the future if we want to apply transformations
    # to all bars
    weeks = svg.append("g")
      .attr("class", "weeks")
      .attr("transform", "translate(17.5, 0)")
    
    # Each bar is actually contained in a g itself
    # That g also contains the number of hours for the bar as text
    data = @getData()

    groups = weeks.selectAll(".bar")
      .data(data)
      .enter().append("g")
        .attr("class", "week")
        .attr("transform", (d, i) -> "translate(#{i * 40}, 0)")
        .attr("data-timestamp", (d) -> d.beginning_of_week)

    # The label for the bar (number of hours aggregated for a given week)
    labels = groups.selectAll("text").data (d) ->
        [d.total]
    
    labels.enter().append("text")
      .attr("text-anchor", "middle")
      .attr 'y', (d) =>
        @height - @heightScale(d) - (if d is 0 then 0 else 10)
      .attr("font-family", "sans-serif")
      .attr("font-size", "11px")
      .attr("fill", "black")
      .text (d) ->
        d + ""
    labels.exit()
      .remove()

    # The bars themselves, data is split up between two objects so that each bar has its own set of data
    rects = groups.selectAll("rect").data (d) ->
        [{value: Math.max(d.total, 0), cssClass: d.cssClass}, {value: Math.max(d.proposed, 0), cssClass: "#{d.cssClass} proposed"}]
    rects.enter().append("rect")
        .attr("x", -@barWidth / 2)
        .attr("width", @barWidth)
        .attr "y", (d) =>
          @height - @heightScale(d.value)
        .attr "height", (d) =>
          @heightScale(d.value)
        .attr "class", (d) ->
          d.cssClass
    
    rects.exit()
      .remove()
    @

  redrawBar: (options) ->
    window.heightScale = @heightScale
    svg = d3.select('svg g.weeks')
    # Find the <g> that groups the two <rect> elements used for the total and the proposed hours
    # and assign the new data to it
    formattedData = [
      { value: options.total, cssClass: "estimates" },
      { value: options.proposed, cssClass: "estimates proposed" }
    ]
    svg.selectAll("g.week[data-timestamp=\"#{options.beginning_of_week}\"] rect").data(formattedData)
      .transition()
      .delay(500)
      .ease("linear")
      .attr("data-value", (d) -> d.value)
      .attr "y", (d) =>
        @height - @heightScale(d.value)
      .attr "height", (d) =>
        @heightScale(d.value)
    # Update the text label as well with the new total value
    svg.select("g.weeks [data-timestamp=\"#{options.beginning_of_week}\"] text").data([options.total])
      .transition()
      .delay(500)
      .ease("linear")
      .attr 'y', (d) =>
        @height - @heightScale(d) - (if d is 0 then 0 else 10)
      .text (d) -> 
        d + ""

  redrawChart: ->
    data = @getData()
    svg = d3.select(@el)
    groups = svg.selectAll("g.week").data(data)
        .attr("data-timestamp", (d) -> d.beginning_of_week)
    groups.selectAll("rect")
      .data (d) ->
        [{value: Math.max(d.total, 0), cssClass: d.cssClass}, {value: Math.max(d.proposed, 0), cssClass: "#{d.cssClass} proposed"}]
      .transition()
      .delay(500)
      .ease("linear")
      .attr("y", (d) => @height - @heightScale(d.value))
      .attr("height", (d) => @heightScale(d.value))
      .attr("class", (d) -> d.cssClass)
    groups.selectAll("text")
     .data (d) ->
       [d.total]
     .transition()
     .delay(200)
     .ease("linear")
     .attr 'y', (d) =>
       @height - @heightScale(d) - (if d is 0 then 0 else 10)
     .text (d) ->
       d + ""
