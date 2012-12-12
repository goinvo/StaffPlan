StaffPlan.Mixins.ValidationHandlers =
  errorHandler: (response, modelName) ->
    errors = JSON.parse response 
    targetDiv = @$el.find("div[data-model=#{modelName}]")
    targetDiv.find('span.validation-errors').remove()
    _.each errors, (value, key) =>
      group = targetDiv.find("[data-attribute=#{key}]").closest('div.control-group')
      group.addClass("error")
      errorList = "<ul>" + (_.map value, (error) -> "<li>#{error}</li>") + "</ul>"
      group.find("div.controls").append("<span class=\"validation-errors\">#{errorList}</span>")
