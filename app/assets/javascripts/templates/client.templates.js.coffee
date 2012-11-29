_templates =
  new:
    newClient: '''
      <form class="form-horizontal">
        <div class="control-group">
          <label class="control-label" for="client_name">Name</label>
          <div class="controls">
            <input id="client_name" data-attribute="name" size="30" type="text" value="{{clientName}}">
          </div>
        </div>
        <div class="control-group">
          <label class="control-label" for="client_description">Description</label>
          <div class="controls">
          <textarea cols="40" id="client_description" data-attribute="description" rows="20">{{clientDescription}}</textarea>
          </div>
        </div>
        <div class="control-group">
          <div class="controls">
            {{#if clientActive}}
              <input checked="checked" id="client_active" data-attribute="active" type="checkbox" value="1">
            {{else}}
              <input id="client_active" data-attribute="active" type="checkbox" value="0">
            {{/if}}
            Active?
          </div>
        </div>
        <div class="form-actions">
          {{#if clientIsNew}}
            <button data-action="save" type="submit" class="btn btn-primary">Save changes</button>
          {{else}}
            <button data-action="update" type="submit" class="btn btn-primary">Update client</button>
          {{/if}}
          <button data-action="cancel" type="button" class="btn">Back to list of clients</button>
        </div>
      </form>
    '''
  index:
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
  show:
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
    


StaffPlan.Templates.Clients =
  index:
    clientInfo: Handlebars.compile _templates.index.clientInfo
  show:
    clientInfo: Handlebars.compile _templates.show.clientInfo
  new:
    newClient: Handlebars.compile _templates.new.newClient
