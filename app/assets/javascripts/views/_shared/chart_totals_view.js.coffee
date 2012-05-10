class ChartTotalsView extends Backbone.View
  ###*
    * Chart total controller.
    * @constructor
    * @param {!Backbone.Model} @user Model to track date data from.
    * @param {!HTMLElement}    @el   Container to add charts to.
  *###
  initialize: (@dates, @models=[], @parentsSelector, @el) ->
    @maxHeight = @el.parents(@parentsSelector).height() - 20
    @render @dates, @models if @dates and @models and @el


  ###*
    * Render week hour counter.
    * @param {!Object} date_range Date range meta from User model.
    * @param {!Array}  models     Models to gather data from.
    * @returns {*}
  *###
  render: (date_range, models) ->
    # Grab data
    data = (get_data date_range, models).sort (a,b) ->
      [[a ,b], [c,d]] = _.map [a.id, b.id], (e) -> e.split("-")
      ( (a - c)/Math.abs(a-c) ) or ((b-d)/Math.abs(b-d)) or 0

    # Scale
    ratio = get_ratio @maxHeight, data
    height = _.bind get_height, null, ratio

    # Render
    chart = d3.select(@el[0])

    list = chart.selectAll("li")
      .data(data, (d) -> d.id)

    list
      .style("height", height)
      .attr("class", get_class)
      .select("span")
        .text(get_value)
    list.enter().append("li")
      .attr("class", get_class)
      .style("height", height)
      .style("background-image", get_gradient)
        .append("span")
        .text(get_value)

    list.exit()
      .remove()


###*
  * Get data for current date range
  * @param {!Object} date_range Date range meta from User model.
  * @param {!Array}  models     Models to gather data from.
  * @returns {!Object}          Mapping of data to weeks for a given date range.
*###
get_data = (date_range, models) ->
  # Gompute
  ww = _.map models, (p) ->
    _.map date_range, (date) ->
      p.work_weeks.find (m) ->
        if m.get('cweek') == date.mweek and m.get('year') == date.year
          m.set "date", date
          true
  # Format data
  ww = _.groupBy _.compact(_.flatten(ww)), (w) ->
    "#{w.get('year')}-#{w.get('cweek')}"

  ww["#{d.year}-#{d.cweek}"] ?= [dummy(d)] for d in date_range # Fill empty weeks

  # Total hours for each week
  _.map ww, (hours, key) ->
    _.reduce hours, (m, o) ->
      m.date = o.get "date"
      m.actual    += (parseInt(o.get('actual_hours'),    10) or 0)
      m.estimated += (parseInt(o.get('estimated_hours'), 10) or 0)
      m.proposed.actual += (parseInt(o.get('actual_hours'),    10) or 0) if o.collection.parent.collection.get(o.get("project_id")).get("proposed")
      m.proposed.estimated += (parseInt(o.get('estimated_hours'), 10) or 0) if o.collection.parent.collection.get(o.get("project_id")).get("proposed")
      m
    , {id: key, actual: 0, estimated: 0, proposed: {actual: 0, estimated: 0}}

###*
  * Determine the ratio to be applied to each bar's height.
  * @param {!Number} u_bound Maximum height.
  * @param {!Object} ww      Mapping of data to weeks.
  * @returns {!Number}       Ratio.
*###
get_ratio = (u_bound, ww) ->
  max = Math.max.apply( null, _.pluck( ww, 'actual' ).concat( _.pluck( ww, 'estimated' ) ) ) || 1
  u_bound / max


###*
  * Determine the correct value for a given week.
  * @param {!Object} d   Object of week and data.
  * @returns {!Number}   Value to display.
*###
get_value = (d) ->
  total = d[if d.date.weekHasPassed then "actual" else "estimated"] or 0

  if total == 0 and d.date.weekHasPassed
    d.estimated or 0
  else
    total

get_proposed_value = (d) ->
  total = d["proposed"][if d.date.weekHasPassed then "actual" else "estimated"] or 0

  if total == 0 and d.date.weekHasPassed
    d.proposed.estimated or 0
  else
    total

get_gradient = (d) ->
  percentage = 100 - ((Math.floor(get_proposed_value(d) / get_value(d) * 10000) / 100) || 0)
  "-webkit-linear-gradient(top, #5E9B69 " + percentage + "%,  #9C0 0%)"
  
###*
  * Determine the correct class for a given week.
  * @param {!@Object} d Object of week and data.
  * @returns {!String} Class for week.
*###
get_class = (d) ->
  if isThisWeek d.date
    if d.actual == 0 then "present" else "passed"
  else if d.date.weekHasPassed
    "passed"
  else
    "future"


###*
  * Determine the correct display height for a given week.
  * @param {!Number) ratio Height ratio.
  * @param {!Object} d     Object of week and data.
  * @returns {!String}     Height, with pixel units, to use.
*###
get_height = (ratio, d) ->
  "#{get_value(d) * ratio}px"


# Current data as `Time` instance
now = new Time

# Make dummy week
dummy = (date) ->
  get: (x) -> if x == "date" then date else 0


@views.shared.ChartTotalsView = ChartTotalsView

