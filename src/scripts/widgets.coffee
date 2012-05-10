define ->
  class Widget
    constructor: (@editor, @node, @data) ->
      @clean_html = @node.outerHTML()

    get_data: ->

    render: ->

  class Container extends Widget

  class Block extends Widget

  class DialogWidget extends Widget

  class LinkedLine extends DialogWidget

  class LinkedImage extends DialogWidget

  class Line extends Widget

  class Markdown extends Widget

  return {
    Container: Container
    Block: Block
    DialogWidget: DialogWidget
    LinkedLine: LinkedLine
    LinkedImage: LinkedImage
    Line: Line
    Markdown: Markdown
  }