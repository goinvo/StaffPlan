class window.StaffPlan.Collections.Assignments extends Backbone.Collection
  model: window.StaffPlan.Models.Assignment
  
  initialize: (models, options) ->
    @parent = options.parent
    
  url: ->
    @parent.url() + "/assignments"