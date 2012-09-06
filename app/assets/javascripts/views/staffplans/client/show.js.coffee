class window.StaffPlan.Views.StaffPlans.Client.Show extends Backbone.View
  className: "client zebra"
  tagName: "section"
  
  templates:
    assignment: '''
    <div class="assignment-row grid-row padded">
      <div class="grid-row-element fixed-180">{{clientName}}</div>
      <div class="grid-row-element fixed-180">{{project.name}}</div>
      <div class="grid-row-element flex work-weeks">work weeks</div>
    </div>
    '''
    
  initialize: ->
    @model = @options.model
    @user = @options.user
    @assignmentTemplate = Handlebars.compile @templates.assignment
    
    @$el.attr('data-client-id', @model.get('id'))
    @$el.append( @user.assignments.filter((assignment) => assignment.get('client_id') != @model.get('id')).map (assignment, index) =>
      project_attributes = StaffPlan.projects.get( assignment.get( 'project_id' ) ).attributes
      client_attributes = @model.attributes
      
      @assignmentTemplate
        assignment: assignment
        clientName: if index == 0 then client_attributes.name else ""
        project: project_attributes 
        client: client_attributes
    )
    
  render: ->
    @$el.appendTo('section.main .content')
    