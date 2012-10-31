class window.StaffPlan.Models.Membership extends StaffPlan.Model
  initialize: (options) ->
    @companyId = options.company_id
  
  url: ->
    mid = if @id then "/#{@id}" else ""
    "/companies/#{@companyId}/memberships#{mid}"

  toJSON: ->
    membership:
      @attributes
