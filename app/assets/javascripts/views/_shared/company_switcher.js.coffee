class StaffPlan.Views.Shared.CompanySwitcher extends Backbone.View
  tagName: "li"
  className: "company-switcher"
    
  initialize: ->

  events:
    "click a.switcher": "changeCompany"

  changeCompany: (event) ->
    event.preventDefault()
    event.stopPropagation()
    selectedCompanyId = $(event.target).data('company-id')
    user = StaffPlan.users.get StaffPlan.currentUser.get('id')
    user.save {current_company_id: selectedCompanyId},
      success: (model, response, options) ->
        window.location.href = "/staffplans/#{user.id}"
    , error: (model, xhr, options) ->
        alert "An error occurred while switching companies. Please try again."
  render: ->
    @$el.html HandlebarsTemplates["shared/company_switcher"]
      userId: StaffPlan.currentUser.get("id")
      companies: StaffPlan.companies.select (obj) -> (obj.id isnt StaffPlan.currentCompany.get("id"))
      currentCompanyName: StaffPlan.currentCompany.get("name")
    @
