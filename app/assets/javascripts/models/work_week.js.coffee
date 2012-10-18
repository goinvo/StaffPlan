class window.StaffPlan.Models.WorkWeek extends Backbone.Model
  toCriteria: =>
    year: @get("year")
    cweek: @get("cweek")
