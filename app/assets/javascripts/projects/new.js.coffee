$('div.client_selector select#project_client_id')
  .change ->
    if $(@).val() == "new"
      $('div.new-client').toggle ->
        $(@).find('input[type="text"]').removeAttr('disabled')
    else
      $('div.new-client').toggle ->
        $(@).find('input[type="text"]').attr('disabled', 'disabled')
$('div.new-client').hide()
