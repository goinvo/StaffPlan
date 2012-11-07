class StaffPlan.Views.DateRangeView extends Support.CompositeView
  className: "date-range"
  attributes:
    style: "margin-left: 40px"
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
  
  render: ->
    d = new XDate()
    data = _.map @collection, (timestamp) ->
      dd = d.setTime(timestamp)
      weekNumber = Math.ceil(dd.getDate() / 7)
      switch weekNumber
        when 1
          month: dd.toString("MMM")
          week: "W" + weekNumber
        when 2
          month: "(#{dd.getFullYear()})"
          week: "W" + weekNumber
        else
          month: "&nbsp;"
          week: "W" + weekNumber
    @$el.html @dateRangeTemplate
      months: _.map(data, (date) -> date['month'])
      weeks: _.map(data, (date) -> date['week'])
     
    @
