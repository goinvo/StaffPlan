_templates =
  show:
    header: '''
      <div class="position-fixed date-paginator"> 
        <div class="fixed-180">
          <a href="#" class="return-false previous pagination" data-action=previous>previous</a>
          <a href="#" class="return-false next pagination" data-action=next>next</a>
        </div>
        <div id="date-target" class="flex margin-left-40">
        </div>
      </div>
      <div class="position-fixed chart-wrapper">
        <div class="fixed-180">&nbsp;</div>
        <div class="flex chart-container margin-left-40"><svg class="user-chart"></svg></div>
      </div>
    '''
    addSomeone: '''
      <select class="unassigned-users">
        {{#unassignedUsers}}
          <option value="{{id}}">{{first_name}} {{last_name}}</option>
        {{/unassignedUsers}}
      </select>
      <a href="/assignments" class="btn btn-primary" data-action="add-user">
        <i class="icon-list icon-white"></i>
        Add user to project
      </a>
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
      
      <div class="control-group initially-hidden">
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
        <label class="control-label" for="project-proposed">Proposed</label>
        <div class="controls">
          <input data-model=project data-attribute=proposed id="project-proposed" type="checkbox">
        </div>
      </div>
      
      <div class="control-group">
        <label class="control-label">
          Payment Frequency
        </label>
        <radiogroup data-model=project data-attribute=payment_frequency>
          <input data-model=project data-attribute=payment_frequency type="radio" checked="checked" value="monthly"> Monthly  
          <input data-model=project data-attribute=payment_frequency type="radio" value="total"> Total
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
      <a href="/projects" data-action="create" class="btn btn-primary">Create project</a>
      <a href="/projects" data-action="cancel" class="btn">Back to list of projects</a>
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
      <div class="position-fixed date-paginator"> 
        <div class="fixed-180">
          <a href="#" class="return-false previous pagination" data-action=previous>previous</a>
          <a href="#" class="return-false next pagination" data-action=next>next</a>
        </div>
        <div id="date-target" class="flex">
        </div>
      </div>
      '''
    actions:
      addProject: '''
        <div class="actions">
          <a href="/projects/new" class="btn btn-primary" data-action="new">
            <i class="icon-list icon-white"></i>
            Add project
          </a>
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
      
      <div class="control-group initially-hidden">
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
      <a href="/projects" data-action="update" class="btn btn-primary">Update project</a>
      <a href="/projects" data-action="cancel" class="btn">Back to list of projects</a>
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
