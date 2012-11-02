class ChartTotalsView extends Backbone.View
  ###*
    * Chart total controller.
    * @constructor
    * @param {!Backbone.Model} @user Model to track date data from.
    * @param {!HTMLElement}    @el   Container to add charts to.
  *###
  initialize: (@dates, @models=[], @parentsSelector, @el) ->
    @maxHeight = @el.parents(@parentsSelector).height() - 20
    if @models.size > 0
      @staffPlanPage = _.has(_.first @models, "users")
    else
      @staffPlanPage = @parentsSelector is ".user-select"
    @render @dates, @models if @dates and @models and @el

  render: (date_range, models) ->
    # Grab data
    data = _.sortBy (get_data date_range, models, @staffPlanPage), (obj) -> obj.id
    # Scale
    ratio = get_ratio @maxHeight, data
    height = _.bind get_height, null, ratio

    # Render
    chart = d3.select(@el[0])

    list = chart.selectAll("li")
      .data(data, (d) -> d.id)

    list
      .style("height", height)
      .style("background-image", get_gradient_moz)
      .style("background-image", get_gradient_webkit)
      .attr("class", get_class)
      .attr("data-year", get_year)
      .attr("data-cweek", get_cweek)
      .select("span")
        .text(get_value)

    list.enter().append("li")
      .attr("class", get_class)
      .attr("data-year", get_year)
      .attr("data-cweek", get_cweek)
      .style("height", height)
      .style("background-image", get_gradient_moz)
      .style("background-image", get_gradient_webkit)
        .append("span")
        .text(get_value)

    list.exit()
      .remove()


get_data = (date_range, models, staffPlanPage) =>
  _.map date_range, (date) =>
    dummy = {id: "#{date.year}-#{date.cweek}", date: date, actual: 0, estimated: 0, proposed: {actual: 0, estimated: 0} }
    weeks = _.map models, (model) -> # Can be a project or a user
      model.work_weeks.selectedSubset().select (week) ->
        week.get('year') is date.year and week.get('cweek') is date.cweek
    if weeks.length is 0
      dummy
    else
      _.reduce (_.flatten weeks), (m, o) ->
        assignment = _.detect window._meta.assignments, (ass) ->
          ass[if staffPlanPage then 'project_id' else 'user_id'] == (o.collection?.parent?.id || -1)
        m.proposed.actual    += (parseInt(o.get('actual_hours'),    10) or 0) if assignment?.proposed || false
        m.proposed.estimated += (parseInt(o.get('estimated_hours'), 10) or 0) if assignment?.proposed || false
        m.actual             += (parseInt(o.get('actual_hours'),    10) or 0)
        m.estimated          += (parseInt(o.get('estimated_hours'), 10) or 0)
        m
      , dummy


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
  return "" if d.date.weekHasPassed || d.date.year == moment().year() and d.date.cweek == (+moment().format('w'))
  percentage = 100 - ((Math.floor(get_proposed_value(d) / get_value(d) * 10000) / 100) || 0)
  "-moz-linear-gradient(to bottom, #5E9B69 " + percentage + "%,  #7EBA8D 0%)"
  
get_gradient_webkit = (d) ->
  return "" if d.date.weekHasPassed || d.date.year == moment().year() and d.date.cweek == (+moment().format('w'))
  percentage = 100 - ((Math.floor(get_proposed_value(d) / get_value(d) * 10000) / 100) || 0)
  "-webkit-linear-gradient(top, #5E9B69 " + percentage + "%,  #7EBA8D 0%)"

get_cweek = (d) ->
  d.date.cweek
  
get_year = (d) ->
  d.date.year
###*
  * Determine the correct class for a given week.
  * @param {!@Object} d Object of week and data.
  * @returns {!String} Class for week.
*###

get_class = (d) ->
  if d.date.year == moment().isoyear() and d.date.cweek == moment().isoweek() 
    if d.actual == 0 then "present" else "passed"
  else if d.date.weekHasPassed
    if d.actual == 0 then "" else "passed"
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

# Make dummy week
dummy = (date) ->
  get: (x) -> if x == "date" then date else 0

@views.shared.ChartTotalsView = ChartTotalsView
