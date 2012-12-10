class window.StaffPlan.Views.Clients.Show extends StaffPlan.View
  className: "short"
  render: ->
    super
    
    @$el.find('section.main').html StaffPlan.Templates.Clients.show.clientInfo
      client: @model.attributes
      projects: @model.get("projects")
    @
