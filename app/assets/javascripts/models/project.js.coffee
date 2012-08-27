class window.StaffPlan.Models.Project extends Backbone.Model
  initialize: ->
    # 
    # @work_weeks = new WorkWeekList @get('work_weeks'),
    #   parent: @
    #   
    # @users = new UserList @get('users'),
    #   parent: @
    # 
    # @bind 'destroy', (event) -> @collection.remove @
  
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