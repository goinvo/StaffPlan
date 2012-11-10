class StaffPlan.Views.WeeklyAggregates extends Support.CompositeView
  WEEK_IN_MILLISECONDS = 7 * 86400 * 1000
  
  initialize: ->
    @model = @options.model
    @begin = @options.begin
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
      @redrawBar(message.cweek, message.year, message.value)
  leave: ->
    @off()
    @remove()
  # We need to retrieve the aggregates for the given date range
  getData: ->
      date = new XDate()
      
      aggs = _.reduce _.range(@begin, @begin + @count * WEEK_IN_MILLISECONDS, WEEK_IN_MILLISECONDS), (memo, timestamp) ->
        date.setTime(timestamp)
        memo["#{date.getFullYear()}-#{date.getWeek()}"] =
          cweek: date.getWeek()
          year: date.getFullYear()
          proposed: 0
          actual_hours: 0
          estimated_hours: 0
        memo
      , {}
      weeks = _.flatten @model.getAssignments().map (assignment) =>
        assignment.work_weeks.between(@begin, @begin + (@count - 1) * WEEK_IN_MILLISECONDS)
      
      aggregates = _.reduce weeks, (memo, week) ->
        memo["#{week['year']}-#{week['cweek']}"]['estimated_hours'] += (week["estimated_hours"] or 0)
        memo["#{week['year']}-#{week['cweek']}"]['actual_hours'] += (week["actual_hours"] or 0)
        memo["#{week['year']}-#{week['cweek']}"]['proposed'] += if week["proposed"] then (week["estimated_hours"] or 0) else 0
        memo
      , aggs
      
      _.map aggregates, (aggregate) ->
        if aggregate.actual_hours isnt 0
          total: aggregate.actual_hours
          proposed: 0
          cssClass: "actuals"
          cweek: aggregate.cweek
          year: aggregate.year
        else
          total: aggregate.estimated_hours
          proposed: aggregate.proposed
          cssClass: "estimates"
          cweek: aggregate.cweek
          year: aggregate.year

  render: ->
    @$el.empty()
    svg = d3.select(@el)
      .attr('width', @chartWidth)
      .attr('height', @height)

    # Scale all the heights so that we don't get overflow on the y-axis
    @heightScale = d3.scale.linear()
      .domain([0, @maxHeight])
      .range([0, @height - 20])
    
    # The data we're visualizing
    # data = @collection.map (aggregate) ->
    #   aggregate.getTotals()

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
      .data(data, (d) -> d.cid)
      .enter().append("g")
        .attr("class", "week")
        .attr("transform", (d, i) -> "translate(#{i * 40}, 0)")
        .attr("data-cweek", (d) -> d.cweek)
        .attr("data-year", (d) -> d.year)

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

  redrawBar: (cweek, year, value) ->
    svg = d3.select('svg g.weeks')
    svg.selectAll("g.week[data-cweek=\"#{cweek}\"][data-year=\"#{year}\"] rect").data([{value: value, cssClass: "estimates"}, {value: value / 2, cssClass: "proposed estimates"}])
      .transition()
      .delay(1000)
      .attr "y", (d) =>
        @height - @heightScale(d.value)
      .attr "height", (d) =>
        @heightScale(d.value)
    svg.select("g.weeks [data-cweek=\"#{cweek}\"][data-year=\"#{year}\"] text").data(value)
      .transition()
      .delay(1000)
      .attr 'y', (d) =>
        @height - @heightScale(d) - (if d is 0 then 0 else 10)
      .text((d) -> d + "")

  redrawChart: ->
    data = @getData()
    svg = d3.select("svg.user-chart")
    groups = svg.selectAll("g.week").data(data)
        .attr("data-cweek", (d) -> d.cweek)
        .attr("data-year", (d) -> d.year)
    groups.selectAll("text")
     .data (d) ->
       [d.total]
     .attr 'y', (d) =>
       @height - @heightScale(d) - (if d is 0 then 0 else 10)
     .text (d) ->
       d + ""
    groups.selectAll("rect")
      .data (d) ->
        [{value: Math.max(d.total, 0), cssClass: d.cssClass}, {value: Math.max(d.proposed, 0), cssClass: "#{d.cssClass} proposed"}]
      .attr("y", (d) => @height - @heightScale(d.value))
      .attr("height", (d) => @heightScale(d.value))
      .attr("class", (d) -> d.cssClass)
