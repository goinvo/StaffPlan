class window.StaffPlan.Views.Projects.New extends StaffPlan.View
  
  tagName: "form"
  className: "form-horizontal short"

  initialize: ->
    @newClient = false
    @clients = @options.clients
    @currentUser = @options.currentUser
     
  events: ->
    "change select#client-picker": "clientSelectionChanged"
    "click div.form-actions a[data-action=create]": "createUser"


  createUser: ->
    formValues = @getFormValues("input, select")
    if @newClient
      # First create the client
      @clients.create { name: formValues.client.name },
        success: (model, response) =>
          @createProject model.id, formValues
        error: (model, response) ->
          # How does one manage to not create a client :/
    else
      @createProject formValues.client.id, formValues

  createProject: (clientId, formValues) ->
    # Each model should expose a whitelistedAttributes so that we only transmit what's needed
    projectAttributes = _.extend (_.pick formValues.project, ['name', 'active', 'payment_frequency', 'cost']),
      company_id: window.StaffPlan.currentCompany.id
      client_id: clientId
    @collection.create projectAttributes,
      success: (model, response) ->
        Backbone.history.navigate("/projects", true)
      error: (model, xhr, options) =>
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
      
      
      
  render: ->
    super
    @$el.find("section.main").append StaffPlan.Templates.Projects.new
      clients: @clients.map (client) -> client.toJSON()
    @$el.find(".initially-hidden").hide()

    @
