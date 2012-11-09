class window.StaffPlan.Models.Project extends StaffPlan.Model
  NAME: "project"
  initialize: ->

  url: ->
    id = if @id? then "/#{@id}" else ""
    if @collection? then "#{@collection.url()}#{id}" else "/projects#{id}"
    
  validate: (attributes) ->
    if @get('name') == ''
      return "Project name is required"
  
  dateRangeMeta: ->
    @view.dateRangeMeta()
  
  getClientId: ->
    @get("client_id") || "new_client"
  
  getAssignments: () ->
    new StaffPlan.Collections.Assignments StaffPlan.assignments.select (assignment) =>
      assignment.get("project_id") is @id

  getUsers: -> new StaffPlan.Collections.Users StaffPlan.users.select (user) =>
      user.getAssignments().any (assignment) =>
        assignment.get "project_id" is @id

  getUnassignedUsers: -> new StaffPlan.Collections.Users StaffPlan.users.select (user) =>
      user.getAssignments().all (assignment) =>
        assignment.get "project_id" isnt @id
