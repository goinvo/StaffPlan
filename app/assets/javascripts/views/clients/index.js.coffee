class window.StaffPlan.Views.Clients.Index extends Backbone.View
  id: "clients"
  className: "padding-top-40"
  
  initialize: ->
    @collection.bind 'change:id', => @render()

  events: ->
    "click a[data-action=delete]": "deleteClient"

  leave: ->
    @unbind()
    @remove()

  deleteClient: (event) ->
    event.preventDefault()
    event.stopPropagation()
    clientId = $(event.target).closest("a[data-action=delete]").data("client-id")
    client = @collection.get(clientId)
    client.destroy()
    @collection.remove(client)
    @$el.find('li[data-client-id=' + clientId + ']').remove()
    
  render: ->
    @$el.html StaffPlan.Templates.Clients.index.clientInfo
      clients: @collection.map (client) ->
        _.extend client.attributes,
          projects: client.getProjects().reduce((hash, project) ->
            hash[project.id] = project.get('name')
            hash
          , {})
      currentCompany: @options.currentCompany
    @
