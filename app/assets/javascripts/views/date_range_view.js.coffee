class StaffPlan.Views.DateRangeView extends Backbone.View
  className: "date-range"
  templates:
    dates: '''
      <a href="#" class="pagination previous" data-action=previous>&lt;</a>
      <div class="week-numbers">
        {{#each weeks}}
          <span class="week-number" data-timestamp={{this.timestamp}}>{{this.week}}</span>
        {{/each}}
      </div>
      <div class="month-names">
        {{#each months}}
          <span class="month-name">{{this}}</span> 
        {{/each}}
      </div>
      <a href="#" class="pagination next" data-action=next>&gt;</a>
    '''
  initialize: ->
    @dateRangeTemplate = Handlebars.compile(@templates.dates)

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
    data = _.map @collection, (timestamp) ->
      m = moment(timestamp)
      weekNumber = Math.ceil(m.date() / 7)
      switch weekNumber
        when 1
          month: m.format("MMM")
          week: "W" + weekNumber
          timestamp: timestamp
        when 2
          if m.month() is 0
            month: "(#{m.year()})"
            week: "W" + weekNumber
            timestamp: timestamp
          else
            month: ""
            week: "W" + weekNumber
            timestamp: timestamp
        else
          month: "&nbsp;"
          week: "W" + weekNumber
          timestamp: timestamp
    @$el.html @dateRangeTemplate
      months: _.map(data, (date) -> date['month'])
      weeks: _.map data, (date) ->
        week: date['week']
        timestamp: data['timestamp']
    m = moment()
    timestampAtBeginningOfWeek = m.utc().startOf('day').subtract('days', m.day() - 1)
    currentWeek = @$el.find "span.week-number[data-timestamp=\"#{timestampAtBeginningOfWeek}\"]"

    @
