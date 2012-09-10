class window.StaffPlan.Views.Clients.Index extends Support.CompositeView
  templates:
    clientInfo: '''
    <h2>List of clients for company <a href="/companies/{{currentCompany.id}}">{{currentCompany.name}}</a></h2> 
    <ul class="clients-list">
      {{#each clients}}
        <li data-client-id="{{this.id}}"> 
          <div class='client-info'>
            <a href="/clients/{{this.id}}">
              <span class='client-name'>
                <a href="/clients/{{this.id}}">
                  {{this.name}}
                </a>
                <span class="separator"> // </span>
                <a href="/clients/{{this.id}}/edit">
                  Edit client {{this.name}}
                </a>
              </span>
            </a>
          </div>
          <a href="/clients/{{this.id}}" data-action="delete" data-client-id="{{this.id}}">Delete client</a>
        </li>
      {{/each}}
    </ul>
    <a href="/clients/new">Add Client</a>
    '''
  
  initialize: ->
    
    @clientInfoTemplate = Handlebars.compile(@templates.clientInfo)
    
    @$el.html @clientInfoTemplate
      clients: @collection.map (client) -> client.attributes
      currentCompany: @options.currentCompany
      
    @render()
    
  events: ->
    "click a[data-action=delete]": "deleteClient"

  deleteClient: (event) ->
    event.preventDefault()
    event.stopPropagation()
    clientId = $(event.currentTarget).data("client-id")
    client = @collection.get(clientId)
    client.destroy()
    @collection.remove(client)
    @$el.find('li[data-client-id=' + clientId + ']').remove()
    
  render: ->
    @$el.appendTo('section.main .content')
