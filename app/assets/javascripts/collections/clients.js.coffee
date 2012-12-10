class window.StaffPlan.Collections.Clients extends Backbone.Collection
  NAME: "clients"
  model: StaffPlan.Models.Client
  
  url: ->
    "/clients"

  comparator: (client) ->
    client.get("name").toLowerCase()
