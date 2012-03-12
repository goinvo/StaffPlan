$ ->
  $('div.client_selector select#project_client_id')
    .change ->
      if $(@).val() == "new"
        $(@).closest('div.client_selector').append '<div class="input"><label for="client_name">Client Name</label><input id="client_name" name="client[name]" size="30" type="text"></div>'
