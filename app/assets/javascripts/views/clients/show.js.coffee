class window.StaffPlan.Views.Clients.Show extends Support.CompositeView
  templates:
    clientInfo: '''
    <div class="client-info">
      <div class="client-name">
        <h3>Name</h3>
        {{client.name}}
      </div>
      <div class="client-description">
        <h3>Description</h3>
        {{client.description}}
      </div>
      <div class="client-active">
        <h3>Status</h3>
        This client is 
        {{#if client.active}}
          active 
        {{else}} 
          inactive
        {{/if}}
      </div>
      <h3>List of {{client.name}}'s projects</h3>
        {{#each projects}}
          <div class="client-project">
            <a href="/projects/{{this.id}}">{{this.name}}</a>
          </div>
        {{/each}}
      </div>
    </div>
    <div class="actions">
      <a class="btn btn-primary btn-large" href="/clients">Back to list of clients</a>
    </div>
    '''
  initialize: ->
    @clientInfoTemplate = Handlebars.compile(@templates.clientInfo)
    @$el.html @clientInfoTemplate
      client: @model.attributes
      projects: @model.get("projects")
    @render()
 
  render: ->
    @$el.appendTo('section..main')
