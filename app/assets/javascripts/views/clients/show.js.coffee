class window.StaffPlan.Views.Clients.Show extends Support.CompositeView
  templates:
    clientInfo: '''
    <div class="client-info">
      The only piece of information we have for now is the name so there it is: <span="client-name">{{client.name}}</span>
    </div>
    '''
  initialize: ->
    @clientInfoTemplate = Handlebars.compile(@templates.clientInfo)
    @$el.html @clientInfoTemplate({client: @model.attributes})
    @render()
 
  render: ->
    @$el.appendTo('section.main .content')
