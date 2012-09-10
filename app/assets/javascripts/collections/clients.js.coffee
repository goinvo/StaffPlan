class window.StaffPlan.Collections.Clients extends Backbone.Collection
  model: window.StaffPlan.Models.Client
  
  url: ->
    "/clients"
