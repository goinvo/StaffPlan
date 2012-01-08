class User extends Backbone.Model
  initialize: (userdata) ->
    
    @fromDate = -> Date.today().addWeeks(-2).moveToDayOfWeek Date.getDayNumberFromName 'Monday', -1
    @toDate   = -> Date.today().add(3).months()
    
    @projects = new ProjectList @get( "projects" ),
      parent: @
    
    @view = new UserView
      model: @
      id: "staffplan_#{@id || @cid}"
    
    @projects.bind 'add', (project) =>
      projects = @projectsByClient()
      @view.renderProjectsForClient project.get("client_id"), projects[ project.get("client_id") ]
      
      setTimeout ->
        $(project.view.el).find('input[name="project[name]"]').focus()
    
    urlRoot: "/users"
  
  dateRangeMeta: ->
    fromDate: @fromDate()
    toDate: @toDate()
    dates: ( =>
      yearsAndWeeks = []
      from = @fromDate()
      
      while from.isBefore @toDate()
        yearsAndWeeks.push
          year: from.getFullYear()
          cweek: from.getISOWeek()
          month: from.getMonth()
          mweek: from.getWeek()
          weekHasPassed: from.isBefore Date.today()
        
        from = from.add(1).week()
      
      yearsAndWeeks
    )()
      
    
  projectsByClient: ->
    
    _.reduce @projects.models, (projectsByClient, project) ->
        projectsByClient[ project.get( 'client_id' ) ] ||= []
        projectsByClient[ project.get( 'client_id' ) ].push project
        projectsByClient
      , {}
  
  url: ->
    "/users/#{@id}"
  
window.User = User