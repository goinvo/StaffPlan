class window.StaffPlan.Collections.Assignments extends Backbone.Collection
  model: StaffPlan.Models.Assignment
  
  initialize: (models, options) ->
    @parent = options.parent
    
    @bind 'change:id', (assignment) ->
      assignment.view.render()
    
  url: ->
    "/assignments"
