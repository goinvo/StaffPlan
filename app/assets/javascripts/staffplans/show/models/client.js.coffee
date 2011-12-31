class Client extends Backbone.Model
  initialize: ->
  
class ClientList extends Backbone.Collection
  model: Client
  
  url: ->
    @parent.url() + "/clients"

window.Client = Client
window.ClientList = ClientList