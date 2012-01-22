class WorkWeekListView extends Backbone.View
  
  tagName: "section"
  className: "work-weeks"
  work_week_list_view_template: $('#work_week_list_view').remove().text()
  
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
          dateObject.actual_hours = workWeek.get('actual_hours')
          dateObject.estimated_hours = workWeek.get('estimated_hours')
          dateObject.cid = workWeek.cid
          
        dateObject
    
    projectExists: =>
      !@model.parent.isNew()
    
  # render/DOM updaters
  render: ->
    $( @el )
      .html( Mustache.to_html( @work_week_list_view_template, @templateData() ) )
    
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
    "keyup input[data-work-week-input]" : "queueUpdateOrCreate"
    
  queueUpdateOrCreate: (event) ->
    window.clearTimeout event.currentTarget.timeout
    event.currentTarget.timeout = setTimeout =>
      @updateOrCreateWorkWeek event
    , 500
    
  updateOrCreateWorkWeek: (event) ->
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
      hash = if attributeName == "estimated_hours"
        {"estimated_hours": $element.val()}
      else
        {"actual_hours": $element.val()}
      
      workWeek.save hash
        
    else
      attributes =
        "cweek": cweek
        "year": year
      attributes[ attributeName ] = $element.val()
      newWorkWeek = new WorkWeek attributes
      
      $element.data cid: newWorkWeek.cid
      
      @model.add newWorkWeek
      newWorkWeek.save {},
        success: (workWeek, response, jqxhr) ->
          if response.status == "ok"
            window._meta.clients.reset response.clients
            workWeek.set response.work_week
            
          else
            alert('Problem saving your entry, please try again')
            $element.removeAttr('value')
    
window.WorkWeekListView = WorkWeekListView