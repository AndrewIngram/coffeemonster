define ['jquery', 'cs!widgets'], ($, widgets) ->
  class Editor
    constructor: (@node, @data, @template) ->
      @node.widgets().each (i, elem) =>
        data = if @data then @data[i] else null
        node = $(elem)
        @editor_for_node node, data

    editor_for_node: (node, data) ->
      widget_name = node.attr('m:widget')
      widget = widgets[widget_name]

      node.data('widget', new widget(this, node, data))

    data_for_node: (node) ->
      node.data('widget').get_data()

    render_node: (node) ->
      node.data('widget').render()

    get_data: ->
      result = []

      @node.widgets().each (i, elem) =>
        node = $(elem)
        data = @data_for_node(node)
        result.push(data)
      return result

    render: (callback) ->
      duplicate = $('<div>#{@template}</div>')
      temp_widgets = duplicate.widgets()

      @node.widgets().each (i, elem) =>
        node = $(elem)
        html = @render_node(node)
        temp_widgets.eq(i).replaceWith(html)

      callback(duplicate.html());
      return duplicate

  return {
    'Editor': Editor,
  }
