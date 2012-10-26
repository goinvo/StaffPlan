class window.StaffPlan.Views.Projects.WorkWeeks extends Backbone.View
  className: "work-weeks"
  tagName: "section"
  
  templates:
    row: '''
    <div class='row-filler'>
      <a href='#'>&rarr;</a>
    </div>
    <div class="grid-row flex">
      <div class='row-label'>Plan</div>
      {{#each visibleWorkWeeks}}
      <input type="text" size="2" data-work-week-input data-current-value="{{estimated_hours}}" data-proposed="{{proposed}}" data-cweek="{{cweek}}" data-year="{{year}}" data-cid="{{cid}}" data-attribute="estimated_hours" value="{{estimated_hours}}" class='estimated-actual' />
      {{/each}}
    </div>
    <div class="grid-row flex">
      <div class='row-label'>Actual</div>
      {{#each visibleWorkWeeks}}
        {{#if hasPassedOrIsCurrent}}
        <input type="text" size="2" data-work-week-input data-current-value="{{actual_hours}} "data-proposed="{{proposed}}" data-cweek="{{cweek}}" data-year="{{year}}" data-cid="{{cid}}" data-attribute="actual_hours" value="{{actual_hours}}" class='estimated-actual' />
        {{/if}}
      {{/each}}
    </div>
    '''
  initialize: ->
    @rowTemplate = Handlebars.compile @templates.row
      

  render: ->
    @$el.empty()
    console.log @collection
    
    weeks = @collection.map (workWeek) -> _.extend(workWeek.attributes, {hasPassedOrIsCurrent: workWeek.hasPassedOrIsCurrent( new XDate() )})
    @$el.append @rowTemplate
      visibleWorkWeeks: weeks
    @rowFiller = @$el.find('.row-filler').hide()
    
    @



