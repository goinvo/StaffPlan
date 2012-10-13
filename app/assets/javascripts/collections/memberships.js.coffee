class window.StaffPlan.Collections.Memberships extends Backbone.Collection
  model: StaffPlan.Models.Membership

  initialize: (models, options) ->
    @parent = options.parent
    
  url: ->
    @parent.url() + "/memberships"
