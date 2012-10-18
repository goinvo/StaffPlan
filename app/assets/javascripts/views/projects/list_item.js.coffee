class window.StaffPlan.Views.Projects.ListItem extends Backbone.View
  templates:
    projectListItem: '''
    <li class="project-list-item" data-project-id="{{project.id}}">
      <div class='project-info'>
        <a href="/projects/{{project.id}}">
          {{project.name}}
        </a>
      </div>
      <div class="controls">
        <a class="btn btn-info btn-small" data-action="show" data-project-id="{{project.id}}" href="/projects/{{project.id}}">
          <i class="icon-white icon-leaf"></i>
          Show
        </a>
        <a class="btn btn-inverse btn-small" data-action="edit" data-project-id="{{project.id}}" href="/projects/{{project.id}}/edit">
          <i class="icon-edit icon-white"></i>
          Edit
        </a>
        <a class="btn btn-danger btn-small" data-action="delete" data-project-id="{{project.id}}">
          <i class="icon-trash icon-white"></i>
          Delete
        </a>
      </div>
    </li>
    '''

  initialize: ->
    @model.on "change", (event) =>
      @render()
    @projectListItemTemplate = Handlebars.compile @templates.projectListItem
    @render()

  render: ->
    @$el.html @projectListItemTemplate
      project: @model.toJSON()
    @
