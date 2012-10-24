class window.StaffPlan.Models.Project extends Backbone.Model
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
