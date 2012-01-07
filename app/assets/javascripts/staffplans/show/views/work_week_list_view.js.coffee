class WorkWeekListView extends Backbone.View
  
  tagName: "table"
  className: "work-weeks"
    
  dateRangeMeta: ->
    @model.dateRangeMeta()
    
  templateData: ->
    meta = @dateRangeMeta()
    
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
    
  render: ->
    $( @el )
      .html( ich.work_week_list_view( @templateData() ) )
    
    
    @
  
  events:
    "keyup input[data-work-week-input]" : "queueUpdateOrCreate"
  
  workWeekByCweekAndYear: (cweek, year) ->
    @model.find (model) ->
      model.get('cweek') == cweek && model.get('year') == year
  
  workWeekByCid: (cid) ->
    @model.getByCid cid
  
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
            workWeek.set JSON.parse response.work_week
            
          else
            alert('error saving that data')
            # TODO: clear out the input value?
    
window.WorkWeekListView = WorkWeekListView