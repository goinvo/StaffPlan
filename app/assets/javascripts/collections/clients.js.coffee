class window.StaffPlan.Collections.Clients extends Backbone.Collection
  NAME: "clients"
  model: StaffPlan.Models.Client
  
  url: ->
    "/clients"

  # Clients should be ordered by name
  # comparator: (first, second) ->
  #   firstName = first.get('name').toLowerCase()
  #   secondName = second.get('name').toLowerCase()
    
  #   if firstName < secondName then -1 else 1
