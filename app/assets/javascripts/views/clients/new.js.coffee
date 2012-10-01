# This view is used by both NEW and EDIT actions
class window.StaffPlan.Views.Clients.New extends Support.CompositeView
  tagName: "form"
  className: "form-horizontal"
  templates:
    newClient: '''
      <div class="control-group">
        <label class="control-label" for="client_name">Name</label>
        <div class="controls">
          <input id="client_name" data-attribute="name" size="30" type="text" value="{{clientName}}">
        </div>
      </div>
      <div class="control-group">
        <label class="control-label" for="client_description">Description</label>
        <div class="controls">
        <textarea cols="40" id="client_description" data-attribute="description" rows="20">{{clientDescription}}</textarea>
        </div>
      </div>
      <div class="control-group">
        <div class="controls">
          {{#if clientActive}}
            <input checked="checked" id="client_active" data-attribute="active" type="checkbox" value="1">
          {{else}}
            <input id="client_active" data-attribute="active" type="checkbox" value="0">
          {{/if}}
          Active?
        </div>
      </div>
      <div class="form-actions">
        {{#if clientIsNew}}
          <button data-action="save" type="submit" class="btn btn-primary">Save changes</button>
        {{else}}
          <button data-action="update" type="submit" class="btn btn-primary">Update client</button>
        {{/if}}
        <button data-action="cancel" type="button" class="btn">Back to list of clients</button>
      </div>
    '''
  
  initialize: ->
    @clientInfoTemplate = Handlebars.compile(@templates.newClient)
    @$el.html @clientInfoTemplate
      clientDescription: @model.get("description") || ""
      clientName: @model.get("name") || ""
      clientActive: if @model.get("active") then "checked=\"checked\"" else ""
      clientIsNew: @model.isNew()
    
    @render()

  events: ->
    "click input#client_active[data-attribute=active]": "updateCheckbox"
    "click div.form-actions > button[type=submit][data-action=save], button[type=submit][data-action=update]": "saveClient"
    "click div.form-actions button[data-action=cancel]": (event) ->
      Backbone.history.navigate("/clients", true)
  
  render: ->
    @$el.appendTo('section.main .content')


  updateCheckbox: ->
    elem = @$el.find("input#client_active")
    elem.val((parseInt($(elem).val(), 10) + 1) % 2)

  saveClient: (event) =>
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
        console.log(response)
        alert "Couldn't save the client to the server :/"
      success: (model, response) =>
        if isNew then @collection.add model
        Backbone.history.navigate(@collection.url(), true)
