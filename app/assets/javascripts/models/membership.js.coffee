class window.StaffPlan.Models.Membership extends StaffPlan.Model
  initialize: (attributes, options={}) ->
    @companyId = options.company_id
    @parent = options.parent
  
  url: ->
    mid = if @id then "/#{@id}" else ""
    "/companies/#{@get('company_id') || @companyId}/memberships#{mid}"

  toJSON: ->
    membership:
      # Permissions
      permissions: @get("permissions") or []
      user_id: @get("user_id")

      # Archived / Disabled
      archived: @get("archived") or false
      disabled: @get("disabled") or false
      # Is the user an intern, a contractor...
      employment_status: @get("employment_status")
      # Salary information for full time employees
      salary: @get("salary") or 0
      full_time_equivalent: @get("full_time_equivalent") or 0
      # Salary information for contractors
      payment_frequency: @get("payment_frequency") or "hourly"
      weekly_allocation: @get("weekly_allocation") or 0
      rate: @get("rate") or 0
