# This view is used by both NEW and EDIT actions
class window.StaffPlan.Views.Clients.New extends Support.CompositeView
  templates:
    newClient: '''
      <div class="input">
        <label for="client_name">Name</label>
        <input id="client_name" data-attribute="name" size="30" type="text" value="{{clientName}}">
      </div>
      <div class="input">
        <label for="client_description">Description</label>
        <textarea cols="40" id="client_description" data-attribute="description" rows="20">{{clientDescription}}</textarea>
      </div>
      <div class="input">
        <label for="client_active">Active</label>
        {{#if clientActive}}
          <input checked="checked" id="client_active" data-attribute="active" type="checkbox" value="1">
        {{else}}
          <input id="client_active" data-attribute="active" type="checkbox" value="0">
        {{/if}}
      </div>
      <div class="actions">
        {{#if clientIsNew}}
          <input name="commit" type="submit" data-action="save" value="Save">
        {{else}}
          <input name="commit" type="submit" data-action="update" value="Update">
        {{/if}}
        <a href="/clients" data-action="cancel">Back to list of clients</a>
      </div>
    '''
  
  initialize: ->
    @clientInfoTemplate = Handlebars.compile(@templates.newClient)
    console.log "CLIENT ACTIF? " + (if @model.get("active") then "YES" else "NO")
    @$el.html @clientInfoTemplate
      clientDescription: @model.get("description") || ""
      clientName: @model.get("name") || ""
      clientActive: if @model.get("active") then "checked=\"checked\"" else ""
      clientIsNew: @model.isNew()
    
    @render()

  events: ->
    "click input#client_active[data-attribute=active]": "updateCheckbox"
    "click div.actions > input[type=submit][data-action=save], input[type=submit][data-action=update]": "saveClient"
  
  render: ->
    @$el.appendTo('section.main .content')


  updateCheckbox: ->
    elem = @$el.find("input#client_active")
    elem.val((parseInt($(elem).val(), 10) + 1) % 2)

  saveClient: (event) =>
    attributes = _.reduce $('[data-attribute]'), (memo, elem) ->
                      memo[$(elem).attr('data-attribute')] = $(elem).val()
                      memo
                    , {}
    isNew = @model.isNew()
    @model.save attributes,
      error: (model, response) =>
        console.log(response)
        alert "Couldn't save the client to the server :/"
      success: (model, response) =>
        if isNew then @collection.add model
        Backbone.history.navigate(@collection.url(), true)
