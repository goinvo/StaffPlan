class StaffPlan.Views.WeeklyAggregates extends Support.CompositeView
  WEEK_IN_MILLISECONDS = 7 * 86400 * 1000
  
  initialize: ->
    @model = @options.model
    @begin = @options.begin
    @count = @options.count
    @height = 75 || @options.height
    @barWidth = 35 || @options.barWidth
    
    @end = @begin + @count * WEEK_IN_MILLISECONDS
    @chartWidth = @count * 40

    @maxHeight = @options.maxHeight

    StaffPlan.Dispatcher.on "date:changed", (message) =>
      @begin = message.begin
      @count = message.count
      @render()

  # We need to retrieve the aggregates for the given date range
  getData: ->
      date = new XDate()
      
      timestampAtBeginningOfCurrentWeek = date.setWeek(date.getWeek(), date.getFullYear()).getTime()
      weeks = @model.getAssignments().map (assignment) =>
        assignment.work_weeks.between(@begin, @end).models
      
      grouped = _.groupBy (_.flatten weeks), (week) ->
        "#{week.get("year")}-#{week.get("cweek")}"
      
      week_range = _.map _.range(@begin, @end, WEEK_IN_MILLISECONDS), (elem) ->
        d = date.clone().setTime(elem)
        "#{d.getFullYear()}-#{d.getWeek()}"
      
      _.reduce week_range, (memo, week) ->
        unless _.has(memo, week)
          memo[week] = [{proposed: false, actual_hours: 0, estimated_hours: 0}]
        memo
      , grouped

      _.map grouped, (value, key) ->
        [year, cweek] = key.split "-"
        agg = _.reduce value, (memo, element) ->
          memo.estimated_hours += element.get("estimated_hours") or 0
          memo.actual_hours    += element.get("actual_hours") or 0
          memo.proposed        += if element.get("proposed") then element.get("estimated_hours") else 0
          memo
        , { proposed: 0, estimated_hours: 0, actual_hours: 0 }
        if agg.actual_hours isnt 0
          total: agg.actual_hours
          proposed: 0
          cweek: cweek
          year: year
          cssClass: "actuals"
        else
          total: agg.estimated_hours
          proposed: agg.proposed
          cweek: cweek
          year: year
          cssClass: "estimates"

  render: ->
    @$el.empty()
    svg = d3.select(@el)
      .attr('width', @chartWidth)
      .attr('height', @height)

    # Scale all the heights so that we don't get overflow on the y-axis
    heightScale = d3.scale.linear()
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
      .attr("transform", "translate(19, 0)")
    
    # Each bar is actually contained in a g itself
    # That g also contains the number of hours for the bar as text
    data = @getData()
    console.log _.map(data, (d) -> d.total)
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
