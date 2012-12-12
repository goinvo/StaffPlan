class window.StaffPlan.Views.Users.Show extends StaffPlan.View
  className: "short"
  
  render: ->
    super
    
    userProjects = @model.getAssignments().map (assignment) ->
      projectId: assignment.get("project_id")
      projectName: window.StaffPlan.projects.get(assignment.get("project_id")).get('name')
      
    @$el.find('section.main').html StaffPlan.Templates.Users.show.userInfo
      user: @model.attributes
      projects: userProjects

    @
