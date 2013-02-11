class window.StaffPlan.Models.UserPreferences extends StaffPlan.Model
  initialize: ->
  url: ->
    "/users/#{@get('user_id')}/preferences"
