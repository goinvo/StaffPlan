class window.StaffPlan.Models.User extends StaffPlan.Model
  initialize: ->
    
    @membership = new StaffPlan.Models.Membership @get( "membership" ),
      parent: @
    
    @bind "remove", () ->
      @destroy()
  
  isArchived: -> @membership.get('archived')
    
  getWorkWeeks: ->
    projectWeeks = _.flatten @getAssignments().map (assignment) -> assignment.get("filteredWeeks") or assignment.work_weeks.models
    new StaffPlan.Collections.WorkWeeks projectWeeks
    
  # Proxy so that the aggregation is generic
  getAssignments: ->
    new StaffPlan.Collections.Assignments StaffPlan.assignments.select (assignment) =>
      assignment.get("user_id") is @id
  
  pick: (attrs) ->
    _.reduce attrs, (memo, elem) =>
      if typeof this[elem] is "function"
        memo[elem] = this[elem].apply(@)
      else
        memo[elem] = @get elem
      memo
    , {}
  
  # Feeds all the necessary information to the template used by users/edit
  getMembershipInformation: ->
    status = _.reduce {"fte": "Full-Time Equivalent", "contractor": "Contractor", "intern": "Intern"}, (memo, value, key) =>
        memo.push
          name: key
          capitalizedName: value
          selected: @membership.get('employment_status') is key
        memo
      , []
    status = _.reduce ['contractor', 'fte'], (memo, prop) =>
      memo[prop] = @membership.get('employment_status') is prop
      memo
    , status
    salary = _.pick @membership.toJSON().membership, ["salary", "full_time_equivalent", "weekly_allocation", "rate"]
    salary['payment_frequency'] = _.reduce ['hourly', 'daily', 'weekly', 'monthly', 'yearly'], (memo, frequency) =>
        memo.push
          name: frequency
          capitalizedName: frequency.charAt(0).toUpperCase() + frequency.slice(1)
          selectedFrequency: @membership.get("payment_frequency") is frequency
        memo
      , []
    _.reduce ["admin", "financials"], (permissionInfo, permission) =>
      permissionInfo['permissions'].push
        name: permission
        userHasPermission: _.include @membership.get('permissions'), permission
        capitalizedName: permission.charAt(0).toUpperCase() + permission.slice(1)
      permissionInfo
    , { disabled: @membership.get('disabled'), archived: @membership.get('archived'), status: status, permissions: [], salary: salary }

  validate: ->
    errors = {}
    _.each ['first_name', 'last_name', 'email'], (property) =>
      if @get(property) is ""
        errors[property] = ["#{property.split("_").join(" ")} cannot be left blank"]
    if _.keys(errors).length > 0
      return {responseText: JSON.stringify(errors)}
  # This function returns the number of estimated hours entered in the future by the user
  workload: ->
    weeks = @getAssignments().map (assignment) ->
      assignment.work_weeks.select (week) ->
        week.get("beginning_of_week") > moment().utc().valueOf()
    _.reduce (_.flatten weeks), (memo, week) ->
      memo += parseInt(week.get("estimated_hours"), 10) or 0
      memo
    , 0

  toJSON: ->
    first_name: @get("first_name")
    last_name: @get("last_name")
    email: @get("email")

  dateChanged: (event) ->
    event.preventDefault()
    interval = if $(event.currentTarget).data().changePage == 'next' then @weekInterval else -@weekInterval
    @fromDate.add('weeks', interval)
    @toDate.add('weeks', interval)
    @view.renderContent()
    @weekHourCounter.render @dateRangeMeta().dates, @projects.models

  dateRangeMeta: ->
    @view.dateRangeMeta()

  projectsByClient: ->
    _.reduce @projects.models, (projectsByClient, project) ->
        clientId = project.getClientId()
        projectsByClient[ clientId ] ||= []
        projectsByClient[ clientId ].push project
        projectsByClient
      , {}
