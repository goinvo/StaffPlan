class window.StaffPlan.Collections.Assignments extends Backbone.Collection
  model: window.StaffPlan.Models.Assignment
  
  url: ->
    @parent.url() + "/assignments"