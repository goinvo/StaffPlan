class StaffPlan.Views.DateRangeView extends Support.CompositeView

  attributes:
    class: "date-range"

  initialize: ->
    @dateRangeTemplate = HandlebarsTemplates["date_range_view/dates"]

    @on "date:changed", (message) ->
      @collection = _.range(message.begin, message.begin + message.count * 7 * 86400 * 1000, 7 * 86400 * 1000)
      @render()

  events:
    "click a.pagination": "paginate"

  paginate: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @parent.trigger "date:changed",
      action: $(event.target).data('action')

  leave: ->
    @unbind()
    @remove()

  render: ->
    displayDates = StaffPlan.users.get(StaffPlan.currentUser.get('id')).preferences.get("display_dates")
    data = _.map @collection, (timestamp) ->
      m = moment(timestamp)
      weekNumber = Math.ceil(m.date() / 7)
      switch weekNumber
        when 1
          month: m.format("MMM")
          week: if displayDates then m.format("M/D") else "W" + weekNumber
          timestamp: timestamp
        when 2
          if m.month() is 0
            month: "(#{m.year()})"
            week: if displayDates then m.format("M/D") else "W" + weekNumber
            timestamp: timestamp
          else
            month: Handlebars.SafeString("&nbsp;")
            week: if displayDates then m.format("M/D") else "W" + weekNumber
            timestamp: timestamp
        else
          month: Handlebars.SafeString("&nbsp;")
          week: if displayDates then m.format("M/D") else "W" + weekNumber
          timestamp: timestamp
    m = moment()
    timestampAtBeginningOfWeek = m.utc().startOf('day').subtract('days', m.day() - 1).valueOf()
    months = data.map (d) ->
      month: d.month
      timestamp: d.timestamp
      highlight: d.timestamp is timestampAtBeginningOfWeek
    weeks = data.map (d) ->
      week: d.week
      timestamp: d.timestamp
      highlight: d.timestamp is timestampAtBeginningOfWeek
    @$el.html @dateRangeTemplate
      months: months
      weeks: weeks

    @
