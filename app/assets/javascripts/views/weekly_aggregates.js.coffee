class StaffPlan.Views.WeeklyAggregates extends Support.CompositeView

  WEEK_IN_MILLISECONDS = 7 * 86400 * 1000

  # TODO: Stuff this in workers or use slices or do something less dumb than doing it serially

  aggregate: (timestamp, yearFilter) ->
    weeks = _.compact _.flatten @model.getAssignments().map (assignment) ->
      models = (if ((localStorage.getItem("yearFilter") == "all") || (localStorage.getItem("yearFilter") == null)) then assignment.work_weeks.models else assignment.get("filteredWeeks"))
      _.detect models, (week) ->
        parseInt(week.get('beginning_of_week'), 10) is parseInt(timestamp, 10)

    aggregate = _.reduce weeks, (memo, week) ->
      memo['estimated_hours'] += (parseInt(week.get("estimated_hours"), 10) or 0)
      memo['actual_hours'] += (parseInt(week.get("actual_hours"), 10) or 0)
      memo['proposed'] += if week.getAssignment().get("proposed") then (parseInt(week.get("estimated_hours"), 10) or 0) else 0
      memo
    , {estimated_hours: 0, actual_hours: 0, proposed: 0, beginning_of_week: timestamp}

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

  isInViewport: ->
    rect = @el.getBoundingClientRect()
    rect.top >= 0 and rect.left >= 0 and rect.bottom <= window.innerHeight and rect.right <= window.innerWidth

  leave: ->
    @off()
    @remove()

  # We need to retrieve the aggregates for the given date range
  getData: ->
    yearFilter = parseInt(localStorage.getItem("yearFilter"), 10)
    range = _.range(@begin, @begin + @count * WEEK_IN_MILLISECONDS, WEEK_IN_MILLISECONDS)
    _.map range, (timestamp) =>
      @aggregate timestamp, yearFilter

  initialize: ->
    @scaleChart = @options.scaleChart
    @begin = @options.begin.valueOf()
    @count = @options.count
    @height = @options.height or 75
    @barWidth = @options.barWidth or 35
    @chartWidth = @count * 40
    redraw = _.bind @redrawChart, @
    @maxHeight = @options.maxHeight

    @on "date:changed", (message) =>
      @begin = message.begin
      @count = message.count
      # All visible views have priority over the others
      if @isInViewport()
        @redrawChart()
      else
        _.delay redraw, 200

    @on "week:updated", (message) => @redrawChart()

  render: ->
    data = @getData()
    busiestWeek = _.max data, (week) ->
      week.total
    @maxTotal = busiestWeek.total
    @relativeHeight = if @maxTotal > 40 then (@maxTotal * 1.375 + 20) else @height
    @$el.empty()
    svg = d3.select(@el)
      .attr('width', @chartWidth)
      .attr('height', if @scaleChart then @relativeHeight else @height)

    # Scale all the heights so that we don't get overflow on the y-axis
    if @scaleChart
      @heightScale = d3.scale.linear()
        .domain([0, Math.max(@maxTotal, 40)])
        .rangeRound([0, Math.max(@maxTotal * 1.375, 55)])
    else
      @heightScale = d3.scale.linear()
        .domain([0, @maxTotal])
        .rangeRound([0, @height - 20])
    # The SVG itself contains a g to group all the elements
    # We might need that in the future if we want to apply transformations
    # to all bars
    if @scaleChart
      weeks = svg.append("g")
        .attr("class", "weeks")
        .attr("transform", "translate(17.5, #{if @maxTotal > 40 then @maxTotal * 1.375 - 55 else 0})")
    else
      weeks = svg.append("g")
        .attr("class", "weeks")
        .attr("transform", "translate(17.5, 0)")

    # Each bar is actually contained in a g itself
    # That g also contains the number of hours for the bar as text

    groups = weeks.selectAll(".bar")
      .data(data)
      .enter().append("g")
        .attr("class", "week")
        .attr("transform", (d, i) -> "translate(#{i * 40}, 0)")
        .attr("data-timestamp", (d) -> d.beginning_of_week)

    # The label for the bar (number of hours aggregated for a given week)
    labels = groups.selectAll("text").data (d) ->
        [{total: d.total, timestamp: d.beginning_of_week}]

    labels.enter().append("text")
      .attr("text-anchor", "middle")
      .attr 'y', (d) =>
        @height - @heightScale(d.total) - (if d.total is 0 then 0 else 10)
      .attr("font-family", "sans-serif")
      .attr("font-size", "11px")
      .attr("class", (d) ->
        m = moment()
        t = m.utc().startOf('day').subtract('days', m.day() - 1).valueOf()
        if d.timestamp is t
          "current-week-highlight"
      )
      .text (d) ->
        d.total + ""
    labels.exit()
      .remove()

    # The bars themselves, data is split up between two objects so that each bar has its own set of data
    rects = groups.selectAll("rect").data (d) ->
        [{value: Math.max(d.total, 0), cssClass: d.cssClass}, {value: Math.max(d.proposed, 0), cssClass: "#{d.cssClass} proposed"}]
    rects.enter().append("path")
      .attr "d", (d) =>
        roundRect(-@barWidth / 2, @height - @heightScale(d.value), @barWidth, @heightScale(d.value), 2, 2, 0, 0)
      .attr "class", (d) ->
        d.cssClass

    rects.exit()
      .remove()

    @

  redrawChart: ->
    data = @getData()
    busiestWeek = _.max data, (week) ->
      week.total
    @relativeHeight = if busiestWeek.total > 40 then (busiestWeek.total * 1.375 + 20) else @height
    if @scaleChart
      svg = d3.select(@el)
        .attr('width', @chartWidth)
        .attr('height', @relativeHeight)
      @heightScale = d3.scale.linear()
        .domain([0, Math.max(busiestWeek.total, 40)])
        .rangeRound([0, Math.max(busiestWeek.total * 1.375, 55)])
      svg.select("g.weeks")
        .attr("transform", "translate(17.5, #{if busiestWeek.total > 40 then busiestWeek.total * 1.375 - 55 else 0})")
    else
      svg = d3.select(@el)
      @heightScale = d3.scale.linear()
        .domain([0, busiestWeek.total])
        .rangeRound([0, @height - 20])
    groups = svg.selectAll("g.week").data(data)
        .attr("data-timestamp", (d) -> d.beginning_of_week)
    groups.selectAll("rect")
      .data (d) ->
        [{value: Math.max(d.total, 0), cssClass: d.cssClass}, {value: Math.max(d.proposed, 0), cssClass: "#{d.cssClass} proposed"}]
      .transition()
      .delay(200)
      .ease("linear")
      .attr("y", (d) => @height - @heightScale(d.value))
      .attr("height", (d) => @heightScale(d.value))
      .attr("class", (d) -> d.cssClass)
    groups.selectAll("text")
     .data (d) ->
       [{total: d.total, timestamp: d.beginning_of_week}]
     .transition()
     .delay(200)
     .ease("linear")
     .attr 'y', (d) =>
       @height - @heightScale(d.total) - (if d.total is 0 then 0 else 10)
      .attr("class", (d) ->
        m = moment()
        t = m.utc().startOf('day').subtract('days', m.day() - 1).valueOf()
        if d.timestamp is t
          "current-week-highlight"
      )
     .text (d) ->
       d.total + ""


#-----------------------------------------------------------------------------
# Utility Functions
#-----------------------------------------------------------------------------

p = (x, y) ->
  "#{x} #{y} "

roundRect = (x, y, width, height, tl = 0, tr = 0, br = 0, bl = 0) ->
  "M" + p(x + tl, y) +
  "L" + p(x + width - tr, y) + "Q" + p(x + width, y) + p(x + width, y + tr) +
  "L" + p(x + width, y + height - br) + "Q" + p(x + width, y + height) + p(x + width - br, y + height) +
  "L" + p(x + bl, y + height) + "Q" + p(x, y + height) + p(x, y + height - bl) +
  "L" + p(x, y + tl) + "Q" + p(x, y) + p(x + tl, y) +
  "Z"

