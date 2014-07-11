class window.StaffPlan.Views.Clients.Index extends StaffPlan.View

  attributes:
    id:    "clients-index"
    class: "extra-short"

  initialize: (options={}) ->
    @collection.bind 'change:id', => @render()
    @options = options
    
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
    super

    @$main ||= @$el.find('section.main')

    @$main.html StaffPlan.Templates.Clients.index.clientInfo
      clients: @collection.map (client) ->
        _.extend client.attributes,
          projects: client.getProjects().reduce((hash, project) ->
            hash[project.id] = project.get('name')
            hash
          , {})
      currentCompany: @options.currentCompany

    @$main.append StaffPlan.Templates.Clients.index.actions.addClient

    @
