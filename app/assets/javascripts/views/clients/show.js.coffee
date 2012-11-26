class window.StaffPlan.Views.Clients.Show extends Support.CompositeView
  initialize: ->
    @$el.html StaffPlan.Templates.Clients.show.clientInfo
      client: @model.attributes
      projects: @model.get("projects")
    @render()
 
  render: ->
    @$el.appendTo('section.main')
