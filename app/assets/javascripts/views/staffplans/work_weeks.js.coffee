class window.StaffPlan.Views.StaffPlans.WorkWeeks extends Backbone.View
  className: "work-weeks"
  tagName: "section"
  
  templates:
    row: '''
    <div class="grid-row flex">
      <div class='row-label'>Plan</div>
      {{#each yearsAndCweeks}}
      <input type="text" size="2" data-cweek="{{mweek}}" data-year="{{year}}" data-cid="{{cid}}" data-attribute="estimated_hours" value="{{estimated_hours}}" class='estimated-actual' />
      {{/each}}
    </div>
    <div class="grid-row flex">
      <div class='row-label'>Actual</div>
      {{#each yearsAndCweeks}}
      <input type="text" size="2" data-cweek="{{mweek}}" data-year="{{year}}" data-cid="{{cid}}" data-attribute="actual_hours" value="{{actual_hours}}" class='estimated-actual' />
      {{/each}}
    </div>
    '''
    
    input: '''
    
    '''
  
  yearsAndCweeks: ->
    debugger
    
  initialize: ->
    @model = @options.model
    @assignment = @options.assignment
    @client = @options.client
    @user = @options.user
    
    @rowTemplate = Handlebars.compile @templates.row
    @inputTemplate = Handlebars.compile @templates.input
    
  render: ->
    
    @$el.append( @user.assignments.map (assignment) =>
      @rowTemplate
        yearsAndCweeks: @model
    )
    
    @
    