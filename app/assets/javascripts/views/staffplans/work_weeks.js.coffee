class window.StaffPlan.Views.StaffPlans.WorkWeeks extends Backbone.View
  className: "work-weeks"
  tagName: "section"
  
  templates:
    row: '''
    <div class="grid-row flex">
      {{#each workWeeks}}
      <input type="text" size="2" data-cweek="{{mweek}}" data-year="{{year}}" data-cid="{{cid}}" data-attribute="{{data_attribute}}" value="{{estimated_hours}}" />
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
    
    @$
    
    @$el.append( @user.assignments.map (assignment) =>
      @assignmentTemplate
        assignment: assignment
        project: StaffPlan.projects.get( assignment.get( 'project_id' ) ).attributes
        client: @model.attributes
    )
    
  render: ->
    @$el.appendTo('section.main .content')
    