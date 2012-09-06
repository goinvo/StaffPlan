class window.StaffPlan.Views.StaffPlans.Assignments.WorkWeeks extends Backbone.View
  className: "work-weeks"
  tagName: "section"
  
  templates:
    input: '''
    <input type="text" size="2" data-cweek="{{ mweek }}" data-year="{{ year }}" data-cid="{{ cid }}" data-attribute="actual_hours" value="{{ actual_hours }}" data-work-week-input />
    '''
    
  initialize: ->
    @model = @options.model
    @user = @options.user
    @assignmentTemplate = Handlebars.compile @templates.assignment
    
    @$el.append( @user.assignments.map (assignment) =>
      @assignmentTemplate
        assignment: assignment
        project: StaffPlan.projects.get( assignment.get( 'project_id' ) ).attributes
        client: @model.attributes
    )
    
  render: ->
    @$el.appendTo('section.main .content')
    