class StaffPlan.Views.WeeklyAggregates extends Support.CompositeView
  initialize: ->

    # NOTE: The models inside this collection shouldn't have to be massaged any further 
    # i.e. if some weeks are emtpy, the collection must contain dummy aggregates to reflect that

    @collection = @options.collection
    @height = 75
    @barWidth = 34


  getWidth: ->
    1000

  render: ->
    # At this point we have an array of objects containing all the information we need to create the bar graph
    # d3 is bound to that data
    chart = d3.select(@el)
      # FIXME: Values are hardwired here
      .attr('width', @getWidth())
      .attr('height', @height)
    
    values = @collection.map (aggregate) ->
      estimated: aggregate.get("totals").estimated
      cid: aggregate.cid

    list = chart.selectAll('rect').data(values, (d) -> d.cid)

    list
      .attr('height', (d) -> d.estimated)
      .attr('width', @barWidth)
      .attr('x', (d, i) -> i * 40)
      .attr('y', (d) => @height - d.estimated)
    list.enter()
      .append('rect')
      .attr('height', (d) -> d.estimated)
      .attr('width', @barWidth)
      .attr('x', (d, i) -> i * 40)
      .attr('y', (d) => @height - d.estimated )
      .attr('class', 'bar')
    @
