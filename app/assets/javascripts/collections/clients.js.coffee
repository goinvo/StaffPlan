class window.StaffPlan.Collections.Clients extends Backbone.Collection
  model: StaffPlan.Models.Client
  
  url: ->
    "/clients"
  
  active: ->
    @select (client) ->
      client.get('active')
  
  comparator: (client) ->
    client.get("name")?.toLowerCase()
