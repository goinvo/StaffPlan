StaffPlan.Mixins.ValidationHandlers =
  errorHandler: (response, modelName) ->
    errors = JSON.parse response 
    targetDiv = @$el.find("div[data-model=#{modelName}]")
    @$el.find('.error').removeClass('error')
    targetDiv.find('span.validation-errors').remove()
    _.each errors, (value, key) =>
      group = targetDiv.find("[data-attribute=#{key}]").closest('div.control-group')
      group.addClass("error")
      errorList = "<ul>" + (_.map value, (error) -> "<li>#{modelName.charAt(0).toUpperCase() + modelName.slice(1)}'s #{error}</li>") + "</ul>"
      group.find("div.controls").append("<span class=\"validation-errors\">#{errorList}</span>")
