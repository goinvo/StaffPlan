window.StaffPlan =
  Models: {}
  Collections: {}
  Templates: {}
  Mixins:
    Events: {}
  Views:
    Layouts: {}
    Shared: {}
    StaffPlans:
      Client: {}
      WorkWeeks: {}
      Assignments: {}
    Assignments: {}
    Users: {}
    Projects:
      WorkWeeks: {}
    Clients: {}
    Planning: {}
  Routers: {}
  Dispatcher: _.extend {}, Backbone.Events
  
  loadData: (type, callback) ->
    $.ajax "/#{type}.json",
      success: (json) =>
        console.log("loaded #{type}")
        @[type] = new StaffPlan.Collections[S(type).capitalize().toString()] json
        @addProgress()
        callback(null, type);
        
      error: =>
        console.log("failed to load #{type}")
        callback("failed to load data for #{type}")
  
  loadAssignments: (callback) ->
    $.ajax "/assignments.json",
      success: (json) =>
        console.log("loaded assignments")
        
        _.forEach json, (assignment) ->
          work_weeks = assignment.work_weeks
          delete assignment.work_weeks
          assignment.work_weeks = _.map work_weeks, (work_week) -> _.object(['id', 'actual_hours', 'estimated_hours', 'beginning_of_week', 'proposed'], work_week)
        
        # work_weeks are sent as an array of arrays with a specific ordering to cut down on bytes sent over the wire.
        @assignments = new StaffPlan.Collections.Assignments json
        
        @addProgress()
        
        # @[type] = new StaffPlan.Collections[S(type).capitalize().toString()] json
        callback(null, "assignments");
        
      error: =>
        console.log("failed to load assignments")
        callback("failed to load data for assignments")
  
  addProgress: ->
    barElement = $('.progress .bar')
    
    if barElement.attr('style') == undefined
      newWidth = "20%"
    else
      newWidth = parseInt(barElement.attr("style").replace(/[\D]*/, ''), 10) + 20 + "%"
    
    barElement.attr("style", "width: #{newWidth}")
    
  initialize: (data) ->
    # show modal blocker
    $(document.body).append(
      '<div class="modal-backdrop"><div class="progress progress-striped"><div class="bar"></div></div></div>'
    )
    
    async.parallel([
      (callback) => @loadAssignments(callback)
      (callback) => @loadData('users', callback)
      (callback) => @loadData('projects', callback)
      (callback) => @loadData('clients', callback)
      ]
      =>
        @addProgress()
        @companies = new Backbone.Collection data.userCompanies
        @currentCompany = @companies.get(data.currentCompanyId)
        @currentUser = @users.get(data.currentUserId)
        @relevantYears = _.reject( _.uniq(_.flatten(StaffPlan.assignments.reduce (memo, assignment) ->
                            memo.push _.uniq(assignment.work_weeks.map (week) -> moment(week.get("beginning_of_week")).year())
                            memo
                          , [])), (year) ->
                            year == 1970 # lol don't ask
                          )
        year = parseInt(localStorage.getItem("yearFilter"), 10)
        if _.include(@relevantYears, year)
          StaffPlan.assignments.each (assignment) ->
            assignment.set "filteredWeeks", assignment.work_weeks.select (week) ->
              moment(week.get("beginning_of_week")).year() is year
    
        @router = new StaffPlan.Routers.StaffPlan
          users: @users
          projects: @projects
          clients: @clients
          currentCompany: @currentCompany
          currentUser: @currentUser
        $ -> Backbone.history.start(pushState: true)
    
        @checkPresence()
    
    
        $(document.body).on 'click', 'a:not([data-bypass])', (event) =>
          event.preventDefault()
          href = $(event.currentTarget).attr('href').slice(1)
      
          unless typeof ga is "undefined"
            ga('send', 'pageview',
              'page': href
            )
      
          Backbone.history.navigate(href, true)
    )
      
  checkPresence: ->
    $.ajax
      url: "/api/presence/ping"
      dataType: "json"
    .fail((jqXHR, textStatus, errorThrown) -> window.location.href = "/sessions/new")
    .done((data, textStatus, jqXHR) ->
      unless window.StaffPlan.sha?
        window.StaffPlan.sha = data.sha
      else if window.StaffPlan.sha != data.sha && confirm("StaffPlan has been updated, please refresh this page to get the latest and greatest. Reload now?")
        window.location.reload()
      
      _.delay(window.StaffPlan.checkPresence, 600000))

  addClientByName: (name, callback) ->
    @clients.create
      name: name
    ,
      success: callback

  addProjectByNameAndClient: (name, client, callback) ->
    @projects.create
      name: name
      client_id: client.get('id')
    ,
      success: callback

  typeAhead: (query, callback) ->
    list = StaffPlan.clients.reduce (array, client) ->
      array.push client.get('name')
      array.push _.map StaffPlan.projects.where(client_id: client.get('id')), (project) ->
        "#{project.get('name')} {#{client.get('name')}}"
      _.flatten array
    , []

    list.push StaffPlan.users.pluck('full_name')
    _.flatten list

  clearTypeAhead: ->
    $('.quick-jump').find('input').val('')

  onTypeAhead: ($form) ->
    typeAheadValue = $form.find('input').val().trim()

    if (match = typeAheadValue.match(/\{(.*)\}/i))?
      clientName = match.pop()
      client = _.detect @clients.models, (client) ->
        client.get('name') == clientName

    if client?
      projectName = typeAheadValue.substr(0, typeAheadValue.indexOf('{')).trim()
      project = client.getProjects().detect (project) ->
        project.get('name') is projectName

      @clearTypeAhead()
      url = "/projects/#{project.get('id')}"

    else if (client = StaffPlan.clients.detect (client) -> client.get('name') == typeAheadValue)?
      @clearTypeAhead()
      url = "/clients/#{client.get('id')}"

    else if (user = StaffPlan.users.detect (user) -> user.get('full_name') == typeAheadValue)?
      @clearTypeAhead()
      url = "/staffplans/#{user.get('id')}"

    Backbone.history.navigate(url, true) if url?
