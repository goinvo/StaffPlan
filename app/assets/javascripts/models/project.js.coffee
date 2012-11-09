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
  
  # Since we don't have a direct association between projects and assignments, we
  # need to go through all the users to find out.
  # Trying to cache those assignments for the subsequent accesses
  getAssignments: () ->
    @assignments ?= StaffPlan.users.reduce (assignments, user) =>
      assignments.add user.assignments.select (assignment) =>
        @id is assignment.get("project_id")
      , silent: true
      
      assignments
    , new StaffPlan.Collections.Assignments [], parent: @
  getUsers: -> new StaffPlan.Collections.Users StaffPlan.users.select (user) =>
      user.assignments.any (assignment) =>
        assignment.get("project_id") is @id

  getUnassignedUsers: -> new StaffPlan.Collections.Users StaffPlan.users.select (user) =>
      user.assignments.all (assignment) =>
        assignment.get("project_id") isnt @id
