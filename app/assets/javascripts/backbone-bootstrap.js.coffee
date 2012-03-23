Time.firstDayOfWeek = 2

window.views =
  staffplans: {}
  projects: {}
window.models = {}

window.isThisWeek = (date) ->
  now = new Time
  date.year == now.year() and date.mweek == now.week()
