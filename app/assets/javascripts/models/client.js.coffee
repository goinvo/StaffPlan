class Client extends Backbone.Model
  
class ClientList extends Backbone.Collection
  model: Client
  
  url: ->
    @parent.url() + "/clients"

window.Client = Client
window.ClientList = ClientList