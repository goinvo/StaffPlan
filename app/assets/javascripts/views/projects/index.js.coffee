class window.StaffPlan.Views.Projects.Index extends Support.CompositeView
  tagName: 'ul'
  className: 'project-list'
  
  initialize: ->
    @collection.bind "remove", () =>
      @render()
  templates:
    header: '''
      <div>
        <h3>List of Projects</h3>
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
  events:
    "click div.controls a[data-action=delete]": "deleteProject"

  deleteProject: ->
    event.preventDefault()
    event.stopPropagation()
    projectId = $(event.target).data("project-id")
    deleteView = new window.StaffPlan.Views.Shared.DeleteModal
      model: @collection.get(projectId)
      collection: @collection
    @$el.append deleteView.render().el
    $('#delete_modal').modal
      show: true
      keyboard: true
      backdrop: 'static'

  render: ->
    @$el.empty()
    @$el.append Handlebars.compile @templates.header
    @collection.each (project) =>
      # For each element in the collection, create a subview
      view = new window.StaffPlan.Views.Projects.ListItem
        model: project
      @$el.append view.render().el
    @$el.append Handlebars.compile @templates.actions.addProject
    @$el.appendTo 'section.main'

    @
