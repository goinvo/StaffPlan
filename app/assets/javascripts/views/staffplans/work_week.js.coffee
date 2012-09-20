class window.StaffPlan.Views.StaffPlans.WorkWeeks extends Backbone.View
  className: "work-weeks"
  tagName: "section"
  
  templates:
    row: '''
    <div class="grid-row flex">
      <div class='row-label'>Plan</div>
      {{#each visibleWorkWeeks}}
      <input type="text" size="2" data-cweek="{{mweek}}" data-year="{{year}}" data-cid="{{cid}}" data-attribute="estimated_hours" value="{{estimated_hours}}" class='estimated-actual' />
      {{/each}}
    </div>
    <div class="grid-row flex">
      <div class='row-label'>Actual</div>
      {{#each visibleWorkWeeks}}
      <input type="text" size="2" data-cweek="{{mweek}}" data-year="{{year}}" data-cid="{{cid}}" data-attribute="actual_hours" value="{{actual_hours}}" class='estimated-actual' />
      {{/each}}
    </div>
    '''
    
    input: '''
    
    '''
  
  initialize: ->
    @model = @options.model
    @assignment = @options.assignment
    @client = @options.client
    @user = @options.user
    
    @rowTemplate = Handlebars.compile @templates.row
    @inputTemplate = Handlebars.compile @templates.input
    
  render: ->
    @$el.empty()
    
    yearsAndWeeks = _.reduce @user.view.getYearsAndWeeks(), (memo, dateMeta) ->
      memo[dateMeta.year] ||= []
      memo[dateMeta.year].push dateMeta.cweek
      memo
    , {}, @
    
    workWeeks = @collection.filter (workWeek) =>
      yearsAndWeeks[workWeek.get('year')] != undefined && _.include(yearsAndWeeks[workWeek.get('year')], workWeek.get('cweek'))
    
    
    @$el.append @rowTemplate
      visibleWorkWeeks: workWeeks
    
    @
    