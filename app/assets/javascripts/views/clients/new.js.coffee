class window.StaffPlan.Views.Clients.New extends StaffPlan.View
  className: "short"
  
  initialize: ->
    _.extend @, StaffPlan.Mixins.ValidationHandlers
  events: ->
    "click input#client_active[data-attribute=active]": "updateCheckbox"
    "click div.form-actions button[type=submit][data-action=save], button[type=submit][data-action=update]": "saveClient"
    "click div.form-actions button[data-action=cancel]": (event) ->
      Backbone.history.navigate("/clients", true)
  
  render: ->
    super
    
    @$el.find('section.main').html StaffPlan.Templates.Clients.new.newClient
      clientDescription: @model.get("description") || ""
      clientName: @model.get("name") || ""
      clientActive: if @model.get("active") then "checked=\"checked\"" else ""
      clientIsNew: @model.isNew()
      
    @


  updateCheckbox: ->
    elem = @$el.find("input#client_active")
    elem.val((parseInt($(elem).val(), 10) + 1) % 2)

  saveClient: (event) ->
    event.preventDefault()
    event.stopPropagation()
    attributes = _.reduce $('[data-attribute]'), (memo, elem) ->
                      memo[$(elem).attr('data-attribute')] = $(elem).val()
                      memo
                    , {}
    debugger
    isNew = @model.isNew()
    if isNew
      @collection.create attributes,
        error: (model, xhr, options) =>
          @errorHandler xhr.responseText, "client"
        success: (model, response) =>
          Backbone.history.navigate(@collection.url(), true)
    else
      @model.save attributes,
        error: (model, xhr, options) =>
          @errorHandler xhr.responseText, "client"
        success: (model, response) =>
          Backbone.history.navigate(@collection.url(), true)
