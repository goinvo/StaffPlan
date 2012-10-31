@instance_store = {}

class StaffPlan.Model extends Backbone.Model

  cache_enabled: false
  cache_key:     "id"

  constructor: (attr) ->
    @on "change:id", @_addToStore
    @on "destroy", @_removeFromStore

    return super unless attr?.id
    id = attr.id
    klass = @_getJsonRoot()
    instance_store[klass] ||= {}

    return(
      if instance_store[klass][id]
         instance_store[klass][id]
      else
        super
        instance_store[klass][id] = this)

  _getJsonRoot: ->
    @jsonRoot ||= @constructor.toString().match(/^function ([\w]+)/i)[1].toLowerCase()

  #--------------------------------------------
  # INSTANCE STORE
  #--------------------------------------------
  _addToStore: =>
    klass = @_getJsonRoot()
    instance_store[klass][@id]
    return
    
  _removeFromStore: =>
    klass = @_getJsonRoot()
    delete instance_store[klass]?[@id]
    return
