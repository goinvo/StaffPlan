class window.StaffPlan.Views.StaffPlans.Client extends Backbone.View
  className: "client zebra"
  tagName: "section"
    
  initialize: ->
    @model = @options.model
    @user = @options.user
    @assignments = @options.assignments
    
    @$el.attr('data-client-id', @model.get('id'))
    
    @assignmentViews = @assignments.map (assignment, index) =>
      new window.StaffPlan.Views.StaffPlans.Assignment
        model: assignment
        client: @model
        user: @user
        index: index
    
    @$el.append @assignmentViews.map (assignment) -> assignment.el
    
  render: ->
    @$el.appendTo('section.main .content .staffplan')
    @assignmentViews.map (assignment) -> assignment.render()
    @