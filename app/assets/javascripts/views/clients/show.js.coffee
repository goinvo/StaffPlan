class window.StaffPlan.Views.Clients.Show extends Support.CompositeView
  templates:
    clientInfo: '''
    <div class="client-info">
      <div class="client-name">
        <h2>Name</h2>
        {{client.name}}
      </div>
      <div class="client-description">
        <h2>Description</h2>
        {{client.description}}
      </div>
      <div class="client-active">
        <h2>Status</h2>
        This client is 
        {{#if client.active}}
          active 
        {{else}} 
          inactive
        {{/if}}
      </div>
      <h2>List of {{client.name}}'s projects</h2>
      <ul class="client-projects">
        {{#each projects}}
          <li class="client-project">
            <a href="/projects/{{this.id}}">{{this.name}}</a>
          </li>
        {{/each}}
      </div>
    </div>
    <div class="actions">
      <a href="/clients">Back to list of clients</a>
    </div>
    '''
  initialize: ->
    @clientInfoTemplate = Handlebars.compile(@templates.clientInfo)
    @$el.html @clientInfoTemplate
      client: @model.attributes
      projects: @model.get("projects")
    @render()
 
  render: ->
    @$el.appendTo('section.main .content')
