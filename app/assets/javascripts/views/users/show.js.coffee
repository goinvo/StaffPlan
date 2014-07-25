class window.StaffPlan.Views.Users.Show extends StaffPlan.View

  attributes:
    id:    "users-new"
    class: "extra-short"
  
  render: ->
    super
    
    userProjects = @model.getAssignments().map (assignment) ->
      projectId: assignment.get("project_id")
      projectName: window.StaffPlan.projects.get(assignment.get("project_id")).get('name')
      
    @$el.find('section.main').html HandlebarsTemplates["users/show/user_info"]
      user: @model.attributes
      projects: userProjects

    @
