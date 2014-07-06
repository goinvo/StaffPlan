class StaffPlan.Views.Shared.Highlighter extends Support.CompositeView
  className: "highlighter"

  initialize: (options={}) ->
    @offset = options.offset
    @height = options.height
    @width = options.width
    @zindex = options.zindex

  render: ->
    @$el.css
      top: @offset.top
      left: @offset.left
      height: "#{@height}px"
      width: "#{@width}px"
    if @zindex?
      @$el.css
        'z-index': @zindex
    @
