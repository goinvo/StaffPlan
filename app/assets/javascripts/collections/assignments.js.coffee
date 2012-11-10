class window.StaffPlan.Collections.Assignments extends Backbone.Collection
  model: StaffPlan.Models.Assignment

  proposed: ->
    new StaffPlan.Collections.Assignments (@select (assignment) -> assignment.get "proposed"),
      parent: @parent

  url: ->
    "/assignments"
