class window.StaffPlan.Collections.Clients extends Backbone.Collection
  model: StaffPlan.Models.Client
  
  url: ->
    "/clients"
