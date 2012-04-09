class views.projects.UserView extends Support.CompositeView

  tagName: "div"
  className: "user"

  initialize: ->
    @userTemplate = Handlebars.compile(@templates.user)
    @headerTemplate = Handlebars.compile(@templates.work_week_header)
    
  render: ->
    meta = @model.collection.parent.view.dateRangeMeta()
    
    $( @el )
      .html( @userTemplate( user: @model.attributes ) )
    @
    
  templates:
    user: '''
    <img src="{{user.gravatar}}" alt="{{user.first_name}} {{user.last_name}}" />
    <span class='name'>{{user.first_name}} {{user.last_name}}</span>
    <div class='months-and-weeks'></div>
    '''
    
    work_week_header: """
    <section>
      <div class='plan-actual'>
        <div class='row-label'>&nbsp;</div>
        {{#each monthNames}}
        <div>{{ name }}</div>
        {{/each}}
        <div class='total'></div>
        <div class='diff-remove-project'></div>
      </div>
      <div class='plan-actual'>
        <div class='row-label'>&nbsp;</div>
        {{#each weeks}}
        <div>{{ name }}</div>
        {{/each}}
        <div class='total'>Total</div>
        <div class='diff-remove-project'></div>
      </div>
    </section>
    """

  # renderWeekHourCounter: ->
  #   # Gompute
  #   dateRange = @model.dateRangeMeta().dates
  #   ww = _.map @model.projects.models, (p) ->
  #     _.map dateRange, (date) ->
  #       p.work_weeks.find (m) ->
  #         m.get('cweek') == date.mweek and m.get('year') == date.year
  # 
  #   # Format data
  #   ww = _.groupBy _.compact(_.flatten(ww)), (w) ->
  #     "#{w.get('year')}-#{w.get('cweek')}"
  # 
  #   # Total hours for each week
  #   _.each ww, (hours, key) ->
  #     ww[key] = _.reduce hours, (m, o) ->
  #       m.actual += (parseInt(o.get('actual_hours'), 10) or 0)
  #       m.estimated += (parseInt(o.get('estimated_hours'), 10) or 0)
  #       m
  #     , {actual: 0, estimated: 0}
  # 
  #   # Scale
  #   whc = @$ '.user-select'
  #   max = Math.max.apply( null, _.pluck( ww, 'actual' ).concat( _.pluck( ww, 'estimated' ) ) ) || 1
  #   ratio = ( whc.height() - 20 ) / max
  # 
  #   # Draw
  #   weekHourCounters = whc.find '.week-hour-counter li'
  #   _.each dateRange, (date, idx) ->
  #     # Map week to <li>
  #     noActualsForWeek = false
  #     li = weekHourCounters.eq(idx)
  #     workWeek = ww["#{date.year}-#{date.mweek}"]
  #     total = if workWeek? then workWeek[if date.weekHasPassed then 'actual' else 'estimated'] else 0
  #     if total == 0 && date.weekHasPassed
  #       noActualsForWeek = true
  #       total = (if workWeek? then workWeek['estimated'] else 0)  || 0
  #       
  #     li
  #       .height(total * ratio)
  #       .html("<span>" + total + "</span>")
  #       .removeClass "present"
  # 
  #     if isThisWeek(date)
  #       if noActualsForWeek then li.addClass "present" else li.addClass "passed"
  #     else if date.weekHasPassed
  #       li.addClass "passed"
  #     else
  #       li.removeClass "passed"

views.projects.UserView= views.projects.UserView