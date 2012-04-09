class views.projects.WorkWeekListView extends Support.CompositeView
  
  tagName: "section"
  className: "work-weeks"

  dateRangeMeta: ->
    @model.dateRangeMeta()
  
  workWeekByCweekAndYear: (cweek, year) ->
    @model.find (model) ->
      model.get('cweek') == cweek && model.get('year') == year

  workWeekByCid: (cid) ->
    @model.getByCid cid
  
  actualTotal: ->
    @model.reduce (total, workWeek, idx, workWeeks) ->
      total += if workWeek.get('actual_hours')? && workWeek.get('actual_hours') != "" then parseInt(workWeek.get('actual_hours'), 10) else 0
      total
    , 0
  
  estimatedTotal: ->
    @model.reduce (total, workWeek, idx, workWeeks) ->
      total += if workWeek.get('estimated_hours')? && workWeek.get('estimated_hours') != "" then parseInt(workWeek.get('estimated_hours'), 10) else 0
      total
    , 0
  
  delta: ->
    @model.reduce (totalDelta, workWeek, idx, workWeeks) ->
      estimated = if workWeek.get('estimated_hours')? && workWeek.get('estimated_hours') != "" then parseInt(workWeek.get('estimated_hours'), 10) else 0
      actual = if workWeek.get('actual_hours')? && workWeek.get('actual_hours') != "" then parseInt(workWeek.get('actual_hours'), 10) else 0
      
      totalDelta += actual - estimated if actual != 0
      totalDelta
    , 0
    
  templateData: ->
    meta = @dateRangeMeta()
    
    isRemoveable: =>
      @model.parent.isNew() || (@actualTotal() == 0 && @estimatedTotal() == 0)
      
    actualTotal: =>
      @actualTotal()
      
    estimatedTotal: =>
      @estimatedTotal()
    
    hasDelta: =>
      @delta() != 0
      
    delta: =>
      @delta()
      
    yearsAndCweeks: =>
      dates = meta.dates
      _.map dates, (dateObject) =>
        workWeek = @workWeekByCweekAndYear dateObject.mweek, dateObject.year
        
        if workWeek?
          dateObject.actual_hours =    (workWeek.get('actual_hours') or '')
          dateObject.estimated_hours = (workWeek.get('estimated_hours') or '')
          dateObject.cid = workWeek.cid
          
        dateObject
    
    projectExists: =>
      !@model.parent.isNew()
  
  templates:
    work_week_list: """
    <div class='row-filler'>
      <a href='#'>&rarr;</a>
    </div>
    <div class='plan-actual'>
      <div class='row-label'>Plan</div>
      {{#yearsAndCweeks}}
      <div>
        <input type="text" size="2" data-cweek="{{ mweek }}" data-year="{{ year }}" data-cid="{{ cid }}" data-attribute="estimated_hours" value="{{ estimated_hours }}" data-work-week-input />
      </div>
      {{/yearsAndCweeks}}
      <div class='total estimated'>{{estimatedTotal}}</div>
      <div class='diff-remove-project'></div>
    </div>
    {{#projectExists}}
    <div class='plan-actual'>
      <div class='row-label'>Actual</div>
      {{#yearsAndCweeks}}
      <div>
        {{#weekHasPassed}}
        <input type="text" size="2" data-cweek="{{ mweek }}" data-year="{{ year }}" data-cid="{{ cid }}" data-attribute="actual_hours" value="{{ actual_hours }}" data-work-week-input />
        {{/weekHasPassed}}
      </div>
      {{/yearsAndCweeks}}
      <div class='total actual'>{{actualTotal}}</div>
      <div class='diff-remove-project'>
        {{#isRemoveable}}
        <a href='#' class='remove-project button-minimal'>&times;</a>
        {{/isRemoveable}}
        <span class='delta'>
          {{#hasDelta}}
          &#916; {{ delta }}
          {{/hasDelta}}
        </span>
      </div>
    </div>
    {{/projectExists}}
    """
    
  # render/DOM updaters
  render: ->
    $( @el )
      .html( Mustache.to_html( @templates.work_week_list, @templateData() ) )

    @rowFiller = @$('.row-filler').hide()
    
    @delegateEvents()
    
    @
  
  updateTotals: ->
    totalDelta = @delta()
    
    if totalDelta != 0
      @$( 'span.delta' ).html "&#916; #{totalDelta}"
    else
      @$( 'span.delta' ).empty()
    
    @$( '.total.estimated' ).text @estimatedTotal()
    @$( '.total.actual' ).text @actualTotal()
  
  # events/handlers
  events:
    "focus  input[data-work-week-input][data-attribute=estimated_hours]": "showRowFiller"
    "blur   input[data-work-week-input][data-attribute=estimated_hours]": "hideRowFiller"
    "keyup  input[data-work-week-input]": "queueUpdateOrCreate"
    "change input[data-work-week-input]": "queueUpdateOrCreate"
    "click  .row-filler": "fillNextRows"

  showRowFiller: (event) ->
    clearTimeout @_rowFillerTimer

    $el = $(event.currentTarget)
    event.currentTarget.type = "number"

    offset = $el.offset()
    offset.top += $el.height()

    @rowFiller
      .show()
      .width($el.outerWidth() - 2)
      .offset(offset)

  hideRowFiller: (event) ->
    @zeroToBlank event # XXX Can't bind multiple methods to the same event via Backbone :(
    event.currentTarget.type = "text"
    @_lastFocused = event.currentTarget
    @_rowFillerTimer = setTimeout =>
      @rowFiller.hide()
    , 150

  fillNextRows: (event) ->
    clearTimeout @_rowFillerTimer
    event.preventDefault()
    event.stopPropagation()
    @_lastFocused.focus()
    $(@_lastFocused).parent().nextAll().find('input[data-work-week-input]')
      .val(@_lastFocused.value)
      .trigger('change')

  zeroToBlank: (event) ->
    if (event.currentTarget.value == '0')
      event.currentTarget.value = ''

  queueUpdateOrCreate: (event) ->
    window.clearTimeout event.currentTarget.timeout
    event.currentTarget.timeout = setTimeout =>
      @updateOrCreateWorkWeek event
    , 500
    
  updateOrCreateWorkWeek: (event) ->
    return if @model.parent.isNew()
    
    event.currentTarget.timeout = null
    
    $element = $( event.currentTarget )
    data = $element.data()
    year = data.year
    cweek = data.cweek
    cid = data.cid
    attributeName = data.attribute
    
    workWeek = if cid != ""
      @workWeekByCid cid
    else
      @workWeekByCweekAndYear cweek, year
    
    if workWeek?
      if $element.val() != ""
        value = parseInt($element.val(), 10)
      else
        value = 0
      
      hash = if attributeName == "estimated_hours"
        {"estimated_hours": value}
      else
        {"actual_hours": value}
      
      workWeek.save hash,
        wait: true
        success: (workWeek, response, jqxhr) =>
          $( document.body ).trigger 'work_week:value:updated'
        
    else
      attributes =
        "cweek": cweek
        "year": year
      attributes[ attributeName ] = $element.val()
      newWorkWeek = new WorkWeek attributes
      
      $element.data cid: newWorkWeek.cid
      
      @model.add newWorkWeek
      newWorkWeek.save {},
        wait: true
        success: (workWeek, response, jqxhr) ->
          if response.status == "ok"
            window._meta.clients.reset response.clients.map (client) -> JSON.parse(client)
            workWeek.set response.work_week
            $( document.body ).trigger 'work_week:value:updated'
            
          else
            # TODO: Flash instead of alert
            alert('Problem saving your entry, please try again')
            $element.removeAttr('value')
    
window.views.projects.WorkWeekListView = views.projects.WorkWeekListView
