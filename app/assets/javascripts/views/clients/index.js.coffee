class window.StaffPlan.Views.Clients.Index extends Support.CompositeView
  id: "clients"
  className: "padding-top-40"
  
  initialize: ->
    Handlebars.registerHelper 'client_projects', (projects) ->
      _.map(projects, (project_name, project_id) ->
        "<a href='/projects/#{project_id}'>#{project_name}</a>"
      ).join(", ")
      
    @populateElement()
    @collection.bind 'change:id', => @render()
    @render()
  
  populateElement: ->
    @$el.html StaffPlan.Templates.Clients.index.clientInfo
      clients: @collection.map (client) ->
        _.extend client.attributes,
          projects: StaffPlan.projects.where(
            client_id: client.id
          ).reduce((hash, project) ->
            hash[project.get('id')] = project.get('name')
            hash
          , {})
      currentCompany: @options.currentCompany
  
  events: ->
    "click a[data-action=delete]": "deleteClient"
    "click button[data-action=new]": (event) ->
      event.preventDefault()
      event.stopPropagation()
      Backbone.history.navigate("/clients/new", true)

  deleteClient: (event) ->
    event.preventDefault()
    event.stopPropagation()
    clientId = $(event.target).closest("a[data-action=delete]").data("client-id")
    client = @collection.get(clientId)
    client.destroy()
    @collection.remove(client)
    @$el.find('li[data-client-id=' + clientId + ']').remove()
    
  render: ->
    @$el.appendTo('section.main')
