$(document)
  .ready ->
    selected = $("select#user_membership_employment_status").val()
    $("div#salary_information div.salary").hide()
    $("div#salary_information div." + selected + "").show()

$('select#user_membership_employment_status')
  .live "change", ->
    selected = $(@).val()
    # Hide all the salary-related information
    $('div#salary_information div.salary').hide()
    # Disable the fields too so that we don't submit information we don't need
    $('div#salary_information').find('input, select').prop('disabled', true)
    # All the fields related to the employment status we selected should be re-enabled, we need those
    $('div#salary_information div.' + selected).find('input, select').show().prop('disabled', false)
    # Show them too, so that the user can interact with them
    $('div#salary_information div.' + selected).show()
