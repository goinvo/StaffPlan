class window.StaffPlan.Models.Client extends StaffPlan.Model
  name: "client"

  # FIXME: Convenience methods that we might want to use in the app, not necessarily heavy on the optimization
  getProjects: ->
    new StaffPlan.Collections.Projects StaffPlan.projects.select (project) =>
      project.get("client_id") is @id

  getAssignments: ->
    new StaffPlan.Collections.Assignments @getProjects().reduce (assignments, project) ->
      assignments.push project.getAssignments().models
      assignments
    , []
