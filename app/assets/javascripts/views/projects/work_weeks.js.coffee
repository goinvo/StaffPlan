class window.StaffPlan.Views.Projects.WorkWeeks extends Support.CompositeView
  className: "work-weeks"
  tagName: "section"
  
  initialize: ->
    @start = @options.start
    @count = @options.count
    
    @on "date:changed", (message) =>
      @start = message.begin
      @count = message.count
      @render()
      
  leave: ->
    @unbind()
    @remove()

  events:
    "focus  input[data-work-week-input][data-attribute='estimated_hours']": "showRowFiller"
    "blur   input[data-work-week-input][data-attribute='estimated_hours']": "hideRowFiller"
    "keyup  input[data-work-week-input][data-attribute='estimated_hours']": "queueEstimatedUpdateOrCreate"
    "keyup  input[data-work-week-input][data-attribute='actual_hours']":    "queueActualUpdateOrCreate"
    "change input[data-work-week-input][data-attribute='estimated_hours']": "queueEstimatedUpdateOrCreate"
    "change input[data-work-week-input][data-attribute='actual_hours']":    "queueActualUpdateOrCreate"
    "click  .row-filler": "fillNextRows"
  
  queueEstimatedUpdateOrCreate: (event) ->

    $currentTarget = $( event.currentTarget )
    cid = $currentTarget.data 'cid'

    @queueUpdateOrCreate event, cid,
      estimated_hours: $currentTarget.val()
    
  queueActualUpdateOrCreate: (event) ->
    $currentTarget = $( event.currentTarget )
    cid = $currentTarget.data 'cid'
    
    @queueUpdateOrCreate event, cid,
      actual_hours: $currentTarget.val()
      
  queueUpdateOrCreate: (event, cid, attributes) ->
    window.clearTimeout event.currentTarget.timeout
    event.currentTarget.timeout = setTimeout =>
      @updateOrCreateWorkWeek event, cid, attributes
    , 500
  
  updateOrCreateWorkWeek: (event, cid, attributes) ->
    event.currentTarget.timeout = null
    workWeek = @collection.get cid

    element = $(event.currentTarget)
    
    workWeek.save attributes,
      error: ->
        alert('Failed to save that hourly data. Try again?')
        
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
    @zeroToBlank event # NOTE: Can't bind multiple methods to the same event via Backbone 
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
    $(@_lastFocused).nextAll('input[data-work-week-input]')
      .val(@_lastFocused.value)
      .trigger('change')

  zeroToBlank: (event) ->
    if (event.currentTarget.value == '0')
      event.currentTarget.value = ''

  render: ->
    @$el.empty()

    range = _.range(@start, @start + @count * 7 * 86400 * 1000, 7 * 86400 * 1000)
    _.each range, (timestamp) =>
      unless (@collection.detect (week) -> week.get("beginning_of_week") is timestamp)?
        @collection.add
          beginning_of_week: timestamp
    weeks = @collection.select (week) ->
      _.include range, week.get("beginning_of_week")

    templateData = _.map weeks, (week) ->
      week.formatForTemplate()
    @$el.append StaffPlan.Templates.StaffPlans.work_week_row
      visibleWorkWeeks: templateData
    @rowFiller = @$el.find('.row-filler').hide()
    
    @
