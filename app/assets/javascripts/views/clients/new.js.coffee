class window.StaffPlan.Views.Clients.New extends Support.CompositeView
  templates:
    newClient: '''
      <div class="input">
        <label for="client_name">Name</label>
        <input id="client_name" data-attribute="name" size="30" type="text" value="{{client.name}}">
      </div>
      <div class="input">
        <label for="client_description">Description</label>
        <textarea cols="40" id="client_description" data-attribute="description" rows="20" value="{{client.description}}">
        </textarea>
      </div>
      <div class="input">
        <label for="client_active">Active</label>
        <input checked="checked" id="client_active" data-attribute="active" type="checkbox" value="1">
      </div>
      <div class="actions">
        <input name="commit" type="submit" data-action="save" value="Save">
        <a href="/clients" data-action="cancel">cancel</a>
      </div>
    '''
  
  initialize: ->
    @clientInfoTemplate = Handlebars.compile(@templates.newClient)
    @$el.html @clientInfoTemplate({client: @model})
    @render()
   
  events: ->
    "click div.actions input[type=submit][data-action=save]": "saveClient"
  
  render: ->
    @$el.appendTo('section.main .content')

  saveClient: (event) =>
    attributes = _.reduce $('[data-attribute]'), (memo, elem) ->
                      memo[$(elem).attr('data-attribute')] = $(elem).val()
                      memo
                    , {}
    @collection.create(attributes)
