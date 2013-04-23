_templates =
  show:
    header: '''
      <div class="lower">
        <div class="grid-row">
          <div class="fixed-180">
            Client: <strong><a href="/clients/{{client_id}}">{{client_name}}</a></strong><br/>
            Project: <strong>{{name}}</strong>
          </div>
          <div id="user-chart" class="flex chart-container margin-left-60"><svg class="user-chart"></svg></div>
        </div>
      </div>
      <div class="header grid-row padded">
        <div class="fixed-180"></div>
        <div class="date-paginator">
          <div id="date-target" class="flex margin-left-60">
          </div>
        </div>
      </div>
    '''
    addSomeone: '''
      <select class="unassigned-users">
        <option value="-1">TBD</option>
        {{#unassignedUsers}}
          <option value="{{id}}">{{first_name}} {{last_name}}</option>
        {{/unassignedUsers}}
      </select>
      <a href="/assignments" class="btn btn-mini" data-action="add-user"><i class="icon-plus"></i></a>
      <a href="/projects/{{projectId}}/edit" class="btn btn-mini">Edit project</a>
      '''

  new: '''
    <div data-model=client>
      <div class="control-group">
        <label class="control-label" for="client-name">
          Client
        </label>
        <div class="controls">
          <select data-model=client data-attribute=id id="client-picker">
            {{#clients}}
              <option value="{{id}}">{{name}}</option>
            {{/clients}}
            <option class="new-client" value="newclient">New Client</option>
          </select>
        </div>
      </div>

      <div class="control-group hidden">
        <label class="control-label" for="client-name">
          Client Name
        </label>
        <div class="controls">
          <input data-model=client data-attribute=name id="client-name" type="text" placeholder="Client Name">
        </div>
      </div>
    </div>

    <div data-model=project>
      <div class="control-group">
        <label class="control-label" for="project-name">
          Project Name
        </label>
        <div class="controls">
          <input data-model=project data-attribute=name id="project-name" type="text" placeholder="Project Name">
        </div>
      </div>

      <div class="control-group">
        <label class="control-label" for="project-active">Active</label>
        <div class="controls">
          <input data-model=project data-attribute=active id="project-active" type="checkbox">
        </div>
      </div>

      <div class="control-group">
        <label class="control-label">
          Payment Frequency
        </label>
        <radiogroup data-model=project data-attribute=payment_frequency>
          <input data-model=project data-attribute=payment_frequency type="radio" name="project_payment" checked="checked" value="monthly"> Monthly
          <input data-model=project data-attribute=payment_frequency type="radio" name="project_payment" value="total"> Total
        </radiogroup>
      </div>

       <div class="control-group">
         <label class="control-label" for="project-cost">Cost</label>
         <div class="controls">
           <input data-model=project data-attribute=cost id="project-cost" size="10" type="number">
         </div>
       </div>
    </div>

    <div class="form-actions">
      <a href="/projects" data-action="create" class="btn btn-primary">Create Project</a>
      <a href="/projects" data-action="cancel" class="btn">Back to Projects</a>
    </div>
    '''

  index:
    listItem: '''
      <div class='project-info fixed-180'>
        <a class="client-name" href="/clients/{{client.id}}">
          {{client.name}}
        </a>
        <a href="/projects/{{project.id}}">
          {{project.name}}
        </a>
      </div>
      <div class="chart-container flex">
        <svg class="user-chart"></svg>
      </div>
      <div class="totals fixed-60"></div>
    '''
    header: '''
      <div class="date-paginator">
        <div class="fixed-180"></div>
        <div id="date-target" class="flex"></div>
      </div>
      '''
    actions:
      addProject: '''
        <div class="actions well">
          <a href="/projects/new" class="btn btn-primary" data-action="new"><i class="icon-plus icon-white" /> Add Project</a>
        </div>
        '''
  edit: '''
    <div data-model=client>

      <div class="control-group">
        <label class="control-label" for="client-name">
          Client
        </label>
        <div class="controls">
          <select data-model=client data-attribute=id id="client-picker">
            {{#clients}}
              <option value="{{id}}">{{name}}</option>
            {{/clients}}
            <option class="new-client" value="newclient">New Client</option>
          </select>
        </div>
      </div>

      <div class="control-group hidden">
        <label class="control-label" for="client-name">
          Client Name
        </label>
        <div class="controls">
          <input data-model=client data-attribute=name id="client-name" type="text" placeholder="Client Name">
        </div>
      </div>

    </div>

    <div data-model=project>

      <div class="control-group">
        <label class="control-label" for="project-name">
          Project Name
        </label>
        <div class="controls">
          <input data-model=project data-attribute=name id="project-name" type="text" placeholder="Project Name">
        </div>
      </div>

      <div class="control-group">
        <label class="control-label" for="project-active">Active</label>
        <div class="controls">
          <input data-model=project data-attribute=active id="project-active" type="checkbox">
        </div>
      </div>

      <div class="control-group">
        <label class="control-label">
          Payment Frequency
        </label>
        <radiogroup data-model="project" data-attribute=payment_frequency>
          <input data-model="project" data-attribute="payment_frequency" name="frequency" type="radio" checked="checked" value="monthly"> Monthly
          <input data-model="project" data-attribute="payment_frequency" name="frequency" type="radio" value="total"> Total
        <radiogroup>
      </div>

       <div class="control-group">
         <label class="control-label" for="project-cost">Cost</label>
         <div class="controls">
           <input data-model=project data-attribute=cost id="project-cost" size="10" type="number">
         </div>
       </div>

    </div>
    <div class="form-actions">
      <a href="/projects" data-action="update" class="btn btn-primary">Update Project</a>
      <a href="/projects" data-action="cancel" class="btn">Back to Projects</a>
    </div>
    '''

StaffPlan.Templates.Projects =
  new: Handlebars.compile _templates.new
  edit: Handlebars.compile _templates.edit
  show:
    header: Handlebars.compile _templates.show.header
    addSomeone: Handlebars.compile _templates.show.addSomeone
  index:
    listItem: Handlebars.compile _templates.index.listItem
    header: Handlebars.compile _templates.index.header
    actions:
      addProject: Handlebars.compile _templates.index.actions.addProject
