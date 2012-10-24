class window.StaffPlan.Views.Clients.Index extends Support.CompositeView
  templates:
    clientInfo: '''
    <h2 class="lead">
      List of clients for company <a href="/companies/{{currentCompany.id}}">{{currentCompany.name}}</a>
    </h2> 
    <ul class="unstyled">
      {{#each clients}}
        <li data-client-id="{{this.id}}">
          <div class='client-info'>
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
        </li>
      {{/each}}
    </ul>
    <button data-action="new" class="btn btn-primary">
      <i class="icon-white icon-list"></i>
      Add client
    </button>
    '''
  
  initialize: ->
    @clientInfoTemplate = Handlebars.compile(@templates.clientInfo)
    
    @populateElement()
    
    @collection.bind 'change:id', => @render()
    
    @render()
  
  populateElement: ->
    @$el.html @clientInfoTemplate
      clients: @collection.map (client) -> client.attributes
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
