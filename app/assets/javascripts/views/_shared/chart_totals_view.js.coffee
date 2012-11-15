class window.StaffPlan.Views.Shared.ChartTotalsView extends Backbone.View
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
    data = (get_data date_range, models)
    # Scale
    ratio = get_ratio @maxHeight, data
    height = _.bind get_height, null, ratio

    # Render
    chart = d3.select(@el[0])

    list = chart.selectAll("li")
      .data(data, (d) -> d.id)
    
    list
      .attr("class", get_class)
      .select("span")
        .text(get_value)

    list.enter().append("li")
      .attr("class", get_class)
      .style("height", height)
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
  # At this point, models should be either an array of User objects or an array of Project objects
  ww = _.map models, (p) ->
    _.map date_range, (date) ->
      p.work_weeks.find (m) ->
        if m.get("beginning_of_week") is date
          m.set "date", date
          true
          
  # Format data
  ww = _.groupBy _.compact(_.flatten(ww)), (w) ->
    "#{w.get("date")}"

  # Total hours for each week
  _.map ww, (hours, key) =>
    _.reduce hours, (m, o) =>
      m.date = o.get "date"
      m.actual    += (parseInt(o.get('actual_hours'),    10) or 0)
      m.estimated += (parseInt(o.get('estimated_hours'), 10) or 0)
      # if @staffPlanPage
      m.proposed.actual += (parseInt(o.get('actual_hours'),    10) or 0) if o.collection?.parent?.collection?.get(o.get("project_id"))?.get("proposed") || false
      m.proposed.estimated += (parseInt(o.get('estimated_hours'), 10) or 0) if o.collection?.parent?.collection?.get(o.get("project_id"))?.get("proposed") || false
      # else
      #   assignment = _.detect window._meta.assignments, (assignment) -> assignment.user_id == (o.collection?.parent?.id || -1)
      #   m.proposed.actual += (parseInt(o.get('actual_hours'),    10) or 0) if assignment?.proposed || false
      #   m.proposed.estimated += (parseInt(o.get('estimated_hours'), 10) or 0) if assignment?.proposed || false
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

get_gradient_moz = (d) ->
  return ""# if d.date.weekHasPassed || d.date.year == (new XDate().getUTCFullYear()) and d.date.cweek == (new XDate().getWeek())
  # percentage = 100 - ((Math.floor(get_proposed_value(d) / get_value(d) * 10000) / 100) || 0)
  # "-moz-linear-gradient(to bottom, #5E9B69 " + percentage + "%,  #7EBA8D 0%)"
  
get_gradient_webkit = (d) ->
  return "" #if d.date.weekHasPassed || d.date.year == (new XDate().getUTCFullYear()) and d.date.cweek == (new XDate().getWeek())
  # percentage = 100 - ((Math.floor(get_proposed_value(d) / get_value(d) * 10000) / 100) || 0)
  # "-webkit-linear-gradient(top, #5E9B69 " + percentage + "%,  #7EBA8D 0%)"
###*
  * Determine the correct class for a given week.
  * @param {!@Object} d Object of week and data.
  * @returns {!String} Class for week.
*###
get_class = (d) ->
  if d.date.year is moment().year() and d.date.cweek is parseInt(moment().format('w'), 10)
    if d.actual is 0 then "present" else "passed"
  else if d.date.weekHasPassed
    if d.actual is 0 then "" else "passed"
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
