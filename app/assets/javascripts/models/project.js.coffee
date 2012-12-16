class window.StaffPlan.Models.Project extends StaffPlan.Model
  initialize: ->

  url: ->
    id = if @id? then "/#{@id}" else ""
    if @collection? then "#{@collection.url()}#{id}" else "/projects#{id}"
  
  validate: ->
    errors = {}
    isSameProject = (@ == StaffPlan.projects.detect (project) => project.get('name') == @get('name'))
    
    _.each ['name', 'cost'], (property) =>
      if @changed[ property ]? && @get(property) is ""
        errors[property] = ["#{property} cannot be left blank"]
    client = StaffPlan.clients.get(@get("client_id"))
    
    if @changed.name? and @isNew() and _.include(client.getProjects().pluck("name"), @get("name"))
      existingProject = client.getProjects().detect (project) =>
        project.get("name") is @get("name")
      errors['name'] ?= []
      errors['name'].push "name already exists for that client (<a href=\"/projects/#{existingProject.id}/edit\">Edit that project instead?</a>)"
      
    if _.keys(errors).length > 0
      return {responseText: JSON.stringify(errors)}

  dateRangeMeta: ->
    @view.dateRangeMeta()
  
  getClientId: ->
    @get("client_id") || "new_client"
  
  getAssignments: () ->
    new StaffPlan.Collections.Assignments StaffPlan.assignments.select (assignment) =>
      assignment.get("project_id") is @id

  getUsers: -> new StaffPlan.Collections.Users @getAssignments().map (assignment) ->
    assignment.get("user_id")

  getWorkWeeks: ->
    projectWeeks = _.flatten @getAssignments().map (assignment) -> assignment.get("filteredWeeks") or assignment.work_weeks.models
    new StaffPlan.Collections.WorkWeeks projectWeeks

  getUnassignedUsers: ->
    userModels = StaffPlan.users.select (user) =>
      _.all user.getAssignments().map (assignment) =>
        assignment.get('project_id') isnt @id
    new StaffPlan.Collections.Users userModels
