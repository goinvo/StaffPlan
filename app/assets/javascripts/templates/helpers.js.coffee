Handlebars.registerHelper 'client_projects', (projects) ->
  _.map(projects, (project_name, project_id) ->
    "<a href='/projects/#{project_id}'>#{project_name}</a>"
  ).join(", ")

Handlebars.registerHelper 'staffplans_show_calendarYears', (dates) ->
  _.uniq(_.pluck dates, 'year').join("/<br/>")
      
Handlebars.registerHelper 'staffplans_show_calendarMonths', (dates) ->
  currentMonthName = null
  _.reduce dates, (html, date, index, dates) ->
    cell_content = ''
          
    unless currentMonthName?
      currentMonthName = moment(date).format "MMM"
      cell_content += "<span class='month-name'>#{currentMonthName}</span>"
    else
      if moment(date).format('MMM') != currentMonthName
        currentMonthName = moment(date).format "MMM"
        cell_content += "<span class='month-name'>#{currentMonthName}</span>"
        
    html += "<div>#{cell_content}</div>"
    html
        
  , ""
      
Handlebars.registerHelper 'staffplans_show_calendarWeeks', (dates) ->
  _.reduce dates, (html, date, index, dates) ->
    html += "<div>W#{Math.ceil(moment(date).date() / 7)}</div>"
    html
  , ""
  
Handlebars.registerHelper 'hours_delta', (total) ->
  if total > 0 then "+#{total}" else "#{Math.abs(total)}"
