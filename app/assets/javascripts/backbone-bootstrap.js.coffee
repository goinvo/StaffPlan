Time.firstDayOfWeek = 2

@models = {}

@views =
  projects:   {}
  shared:     {}
  staffplans: {}

# XXX This should be in `Time`
@isThisWeek = (date) ->
  now = new Time
  date.year == now.year() and date.mweek == now.week()

