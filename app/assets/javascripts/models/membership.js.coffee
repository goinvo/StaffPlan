class window.StaffPlan.Models.Membership extends Backbone.Model
  initialize: ->
    @set "company_id", window.StaffPlan.currentCompany.id
