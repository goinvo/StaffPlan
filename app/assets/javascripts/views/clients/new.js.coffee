class window.StaffPlan.Views.Clients.New extends Backbone.View
  tagName: "form"
  className: "form-horizontal"
  
  initialize: ->
    @$el.html StaffPlan.Templates.Clients.new.newClient
      clientDescription: @model.get("description") || ""
      clientName: @model.get("name") || ""
      clientActive: if @model.get("active") then "checked=\"checked\"" else ""
      clientIsNew: @model.isNew()
    
  events: ->
    "click input#client_active[data-attribute=active]": "updateCheckbox"
    "click div.form-actions button[type=submit][data-action=save], button[type=submit][data-action=update]": "saveClient"
    "click div.form-actions button[data-action=cancel]": (event) ->
      Backbone.history.navigate("/clients", true)
  
  render: ->
    @$el.appendTo('section.main')


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
    isNew = @model.isNew()
    if isNew
      @collection.add @model
    @model.save attributes,
      error: (model, response) =>
        console.log response
        alert "Couldn't save the client to the server :/"
      success: (model, response) =>
        if isNew then @collection.add model
        Backbone.history.navigate(@collection.url(), true)
