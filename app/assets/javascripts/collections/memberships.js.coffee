class window.StaffPlan.Collections.Memberships extends Backbone.Collection
  model: window.StaffPlan.Models.Membership

  # /users/:user_id/memberships (or possibly /companies/:company_id/memberships) 
  url: ->
    @parent.url() + "/memberships"
