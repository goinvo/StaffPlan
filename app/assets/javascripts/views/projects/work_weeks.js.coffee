class window.StaffPlan.Views.Projects.WorkWeeks extends Backbone.View
  className: "work-weeks"
  tagName: "section"
  
  templates:
    row: '''
    <div class='row-label'>Plan</div>
    {{#each visibleWorkWeeks}}
      <input type="text" size="2" data-work-week-input data-current-value="{{estimated_hours}}" data-proposed="{{proposed}}" data-cweek="{{cweek}}" data-year="{{year}}" data-cid="{{cid}}" data-attribute="estimated_hours" value="{{estimated_hours}}" class='estimated-actual' />
    {{/each}}
    <div>
    <div class='row-label'>Actual</div>
    {{#each visibleWorkWeeks}}
      {{#if hasPassedOrIsCurrent}}
        <input type="text" size="2" data-work-week-input data-current-value="{{actual_hours}} "data-proposed="{{proposed}}" data-cweek="{{cweek}}" data-year="{{year}}" data-cid="{{cid}}" data-attribute="actual_hours" value="{{actual_hours}}" class='estimated-actual' />
      {{/if}}
    {{/each}}
    '''
  initialize: ->
    @rowTemplate = Handlebars.compile @templates.row

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
    workWeek = @collection.getByCid cid
    workWeek.save attributes,
      success: (lol, foo, bar, baz) ->
        console.log('success')
      error: (wat, another, argument, here) ->
        alert('fail')
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
    $(@_lastFocused).parent().nextAll().find('input[data-work-week-input]')
      .val(@_lastFocused.value)
      .trigger('change')

  zeroToBlank: (event) ->
    if (event.currentTarget.value == '0')
      event.currentTarget.value = ''

  render: ->
    @$el.empty()
    
    @$el.append @rowTemplate
      visibleWorkWeeks: @collection.map (workWeek) ->
        workWeek.formatForTemplate()

    @rowFiller = @$el.find('.row-filler').hide()
    
    @
