class window.StaffPlan.Views.Clients.Index extends Support.CompositeView
  templates:
    clientInfo: '''
    <li>
      <div class='client-info'>
        <a href="/clients/{{client.id}}">
          <span class='client-name'>
            <a href="/clients/{{client.id}}">{{client.name}}</a>
          </span>
        </a>
      </div>
    </li>
    <a href="/clients/new">Add Client</a>
    '''
  
  initialize: ->
    
    @clientInfoTemplate = Handlebars.compile(@templates.clientInfo)
    
    @$el.html @collection.map (client) => @clientInfoTemplate client: client.attributes
      
    @render()
    
  render: ->
    @$el.appendTo('section.main .content')
