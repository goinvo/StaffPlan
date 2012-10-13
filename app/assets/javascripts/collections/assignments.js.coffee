class window.StaffPlan.Collections.Assignments extends Backbone.Collection
  model: StaffPlan.Models.Assignment
  
  initialize: (models, options) ->
    @parent = options.parent
    
    @bind 'sync', (assignment) ->
      StaffPlan.projects.fetch
        success: ->
          assignment.view.project = StaffPlan.projects.get( assignment.get 'project_id' )
          assignment.view.render()
    
  url: ->
    "/assignments"
