window.views =
  staffplans: {}
  projects: {}
window.models = {}

isThisWeek = (date) ->
  now = new Time
  date.year == now.year() and date.mweek == now.week()
