class window.StaffPlan.Models.Membership extends StaffPlan.Model
  initialize: (options) ->
    @companyId = options.company_id
  
  url: ->
    mid = if @id then "/#{@id}" else ""
    "/companies/#{@companyId}/memberships#{mid}"

  toJSON: ->
    membership:
      archived: @get("archived")
      company_id: @get("company_id")
      disabled: @get("disabled")
      employment_status: @get("employment_status")
      full_time_equivalent: @get("full_time_equivalent")
      id: @get("id")
      payment_frequency: @get("payment_frequency")
      

