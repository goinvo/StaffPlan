class window.StaffPlan.Models.Client extends StaffPlan.Model
  name: "client"

  # FIXME: Convenience methods that we might want to use in the app, not necessarily heavy on the optimization
  getProjects: ->
    new StaffPlan.Collections.Projects StaffPlan.projects.select (project) =>
      project.get("client_id") is @id

  validate: ->
    errors = {}
    if @get("name") is ""
      errors['name'] = ["name cannot be left blank"]
    else
      if _.include StaffPlan.clients.pluck("name"), @get("name")
        errors['name'] = ["name has already been taken"]
    if _.keys(errors).length > 0
      return {responseText: JSON.stringify(errors)}

  getAssignments: ->
    new StaffPlan.Collections.Assignments @getProjects().reduce (assignments, project) ->
      assignments.push project.getAssignments().models
      assignments
    , []
