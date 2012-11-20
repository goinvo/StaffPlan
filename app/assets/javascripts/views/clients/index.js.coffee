class window.StaffPlan.Views.Clients.Index extends Support.CompositeView
  id: "clients"
  className: "padding-top-40"
  templates:
    clientInfo: '''
    <h2 class="lead">
      <a href="/companies/{{currentCompany.id}}">{{currentCompany.name}}</a> &rarr; Clients
    </h2> 
    <ul class="list slick unstyled">
      {{#each clients}}
        <li class='list-item' data-client-id="{{this.id}}">
          <div class='client-name client-info'>
            <a href="/clients/{{this.id}}">
              {{this.name}}
            </a>
          </div>
          <div class="controls"> 
            <a class="btn btn-info btn-small" href="/clients/{{this.id}}/edit">
              <i class="icon-white icon-edit"></i>
              Edit
            </a>
            <a class="btn btn-danger btn-small" href="/clients/{{this.id}}" data-action="delete" data-client-id="{{this.id}}">
              <i class="icon-white icon-trash"></i>
              Delete
            </a>
          </div>
          <div class='client-projects ellipsis flex'>
            {{{client_projects this.projects}}}
          </div>
        </li>
      {{/each}}
    </ul>
    <button data-action="new" class="btn btn-primary">
      <i class="icon-white icon-list"></i>
      Add client
    </button>
    '''
  
  initialize: ->
    Handlebars.registerHelper 'client_projects', (projects) ->
      _.map(projects, (project_name, project_id) ->
        "<a href='/projects/#{project_id}'>#{project_name}</a>"
      ).join(", ")
      
    @clientInfoTemplate = Handlebars.compile(@templates.clientInfo)
    @populateElement()
    @collection.bind 'change:id', => @render()
    @render()
  
  populateElement: ->
    @$el.html @clientInfoTemplate
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
