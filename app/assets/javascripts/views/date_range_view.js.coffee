class StaffPlan.Views.DateRangeView extends Support.CompositeView

  attributes:
    class: "date-range"

  templates:
    dates: '''
      <a href="#" class="pagination previous" data-action=previous>&lt;</a>
      <div class="week-numbers">
        {{#each weeks}}
          {{#if this.highlight}}
            <span class="week-number current-week-highlight" data-timestamp="{{this.timestamp}}">{{this.week}}</span>
          {{else}}
            <span class="week-number" data-timestamp="{{this.timestamp}}">{{this.week}}</span>
          {{/if}}
        {{/each}}
      </div>
      <div class="month-names">
        {{#each months}}
          {{#if this.highlight}}
            <span class="month-name current-week-highlight" data-timestamp="{{this.timestamp}}">{{this.month}}</span> 
          {{else}}
            <span class="month-name" data-timestamp="{{this.timestamp}}">{{this.month}}</span> 
          {{/if}}
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
    displayDates = StaffPlan.users.get(StaffPlan.currentUser.id).preferences.get("display_dates")
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
            month: "&nbsp;"
            week: if displayDates then m.format("M/D") else "W" + weekNumber
            timestamp: timestamp
        else
          month: "&nbsp;"
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
