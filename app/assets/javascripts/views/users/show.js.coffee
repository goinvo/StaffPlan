class window.StaffPlan.Views.Users.Show extends Support.CompositeView
  className: "padding-top-40"
  
  initialize: ->
    
  render: ->
    userProjects = @model.getAssignments().map (assignment) ->
      projectId: assignment.get("project_id")
      projectName: window.StaffPlan.projects.get(assignment.get("project_id")).get('name')
    @$el.html StaffPlan.Templates.Users.show.userInfo
      user: @model.attributes
      projects: userProjects
    @$el.appendTo('section.main')

