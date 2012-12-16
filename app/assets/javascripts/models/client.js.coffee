class window.StaffPlan.Models.Client extends StaffPlan.Model
  name: "client"

  # FIXME: Convenience methods that we might want to use in the app, not necessarily heavy on the optimization
  getProjects: ->
    new StaffPlan.Collections.Projects StaffPlan.projects.select (project) =>
      project.get("client_id") is @id

  validate: (attributes, collection) ->
    errors = {}
    isSameClient = (@ == StaffPlan.clients.detect (client) => client.get('name') == @get('name'))
      
    if !isSameClient && @get("name") is ""
      errors['name'] = ["name cannot be left blank"]
    else
      if !isSameClient && _.include StaffPlan.clients.pluck("name"), @get("name")
        errors['name'] = ["name has already been taken"]
        
    if _.keys(errors).length > 0
      return {responseText: JSON.stringify(errors)}

  getAssignments: ->
    new StaffPlan.Collections.Assignments @getProjects().reduce (assignments, project) ->
      assignments.push project.getAssignments().models
      assignments
    , []
