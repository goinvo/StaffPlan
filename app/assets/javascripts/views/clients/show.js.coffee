class window.StaffPlan.Views.Clients.Show extends StaffPlan.View

  attributes:
    id:    "clients-show"
    class: "extra-short"

  render: ->
    super
    
    @$el.find('section.main').html HandlebarsTemplates["clients/show"]
      client: @model.attributes
      projects: @model.get("projects")
    @
