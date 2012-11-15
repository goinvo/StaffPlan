class StaffPlan.Views.DateRangeView extends Support.CompositeView
  className: "date-range"
  templates:
    dates: '''
      <div class="week-numbers">
        {{#each weeks}}
          <span class="week-number">{{this}}</span>
        {{/each}}
      </div>
      <div class="month-names">
        {{#each months}}
          <span class="month-name">{{this}}</span> 
        {{/each}}
      </div>
    '''
  initialize: ->
    @dateRangeTemplate = Handlebars.compile(@templates.dates)
    StaffPlan.Dispatcher.on "date:changed", (message) =>
      @collection = _.range(message.begin, message.begin + message.count * 7 * 86400 * 1000, 7 * 86400 * 1000)
      @render()

  render: ->
    data = _.map @collection, (timestamp) ->
      m = moment(timestamp)
      weekNumber = Math.ceil(m.date() / 7)
      switch weekNumber
        when 1
          month: m.format("MMM")
          week: "W" + weekNumber
        when 2
          if m.month() is 0
            month: "(#{m.year()})"
            week: "W" + weekNumber
          else
            month: ""
            week: "W" + weekNumber
        else
          month: "&nbsp;"
          week: "W" + weekNumber
    @$el.html @dateRangeTemplate
      months: _.map(data, (date) -> date['month'])
      weeks: _.map(data, (date) -> date['week'])
     
    @
