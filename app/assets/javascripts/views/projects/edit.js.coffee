class window.StaffPlan.Views.Projects.Edit extends StaffPlan.View
  
  tagName: "form"
  className: "form-horizontal short"

  initialize: ->
    @newClient = false
    @clients = @options.clients
    @currentUser = @options.currentUser
     
  events: ->
    "change select#client-picker": "clientSelectionChanged"
    "click div.form-actions a[data-action=update]": "updateUser"


  updateUser: ->
    event.preventDefault()
    event.stopPropagation()
    formValues = @getFormValues("input, select")
    if @newClient
      # First create the client
      @clients.create { name: formValues.client.name },
        success: (model, response) =>
          @updateProjectAndAssignment model.id, formValues
        error: (model, response) ->
    else
      @updateProject formValues.client.id, formValues

  updateProject: (clientId, formValues) ->
    # Each model should expose a whitelistedAttributes so that we only transmit what's needed
    projectAttributes = _.extend (_.pick formValues.project, ['name', 'active', 'payment_frequency', 'cost']),
      company_id: window.StaffPlan.currentCompany.id
      client_id: clientId
    @model.save projectAttributes,
      success: (model, response) ->
        Backbone.history.navigate("/projects", true)
      error: (model, xhr, options) =>
        debugger
        errors = JSON.parse xhr.responseText
        projectDiv = @$el.find('div[data-model=project]')
        _.each errors, (value, key) =>
          group = projectDiv.find("[data-attribute=#{key}]").closest('div.control-group')
          group.addClass("error")
          errorList = "<ul>" + (_.map value, (error) -> "<li>#{error}</li>") + "</ul>"
          group.find("div.controls").append("<span class=\"validation-errors\">#{errorList}</span>")

  clientSelectionChanged: (event) ->
    newClientSelected = $(event.currentTarget).find("option:selected").hasClass "new-client"
    if @newClient isnt newClientSelected
      @$el.find(".initially-hidden").fadeToggle "slow"
    @newClient = newClientSelected

  
  # TODO: Only handles base elements like inputs and selects
  getFormValues: (selector) ->
    _.reduce @$el.find(selector), (values, formElement) =>
      values[$(formElement).data('model')][$(formElement).data('attribute')] = @getFormElementValue formElement
      values
    , _.chain(@$el.find selector)
        .map( (e) ->
          $(e).data "model"
        )
        .uniq()
        .reduce( (m, e) ->
          m[e] = {}
          m
        , {}
        )
        .value()
  
  getFormElementValue: (element) ->
    switch $(element).prop('tagName').toLowerCase()
      when "select"
        return $(element).val()
      when "input"
        switch $(element).attr "type"
          when "number", "text"
            return $(element).val()
          when "radio"
            $(element).closest('radiogroup').find('input[type=radio]:checked').val()
          when "checkbox"
            return $(element).prop "checked"
      
  populateFields: ->
    unless @model.isNew()
      attrs = @model.toJSON()
      
      @$el
        .find("select[data-model=client][data-attribute=id]")
        .val(attrs.client_id)
      
      _.each ["name", "cost"], (prop) =>
        @$el
          .find("[data-model=project][data-attribute=#{prop}]")
          .val(attrs[prop])
      
          
      @$el
        .find("radiogroup[data-model=project][data-attribute=payment_frequency]")
        .find("input[type=radio]")
        .prop("checked", false)
      @$el
        .find("radiogroup[data-model=project][data-attribute=payment_frequency]")
        .find("input[type=radio][value=#{attrs.payment_frequency}]")
        .prop("checked", true)
      
        @$el
          .find("[data-model=project][data-attribute=\"active\"]")
          .prop "checked", attrs["active"]
  render: ->
    super
    @$el.find("section.main").html StaffPlan.Templates.Projects.edit
      clients: @clients.map (client) -> client.toJSON()
    @populateFields()
    @$el.find(".initially-hidden").hide()

    @
