class window.StaffPlan.Views.Clients.Show extends Support.CompositeView
  className: "padding-top-40"
  initialize: ->
    @$el.html StaffPlan.Templates.Clients.show.clientInfo
      client: @model.attributes
      projects: @model.get("projects")
    @render()
 
  render: ->
    @$el.appendTo('section.main')
