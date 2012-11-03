class window.StaffPlan.Collections.Assignments extends Backbone.Collection
  NAME: "assignments"
  model: StaffPlan.Models.Assignment
  
  initialize: (models, options) ->
    @parent = options.parent

  proposed: () ->
    new StaffPlan.Collections.Assignments (@select (assignment) -> assignment.get "proposed"),
      parent: @parent

  url: ->
    "/assignments"
