define ['jquery', 'cs!fields'], ($, fields) ->
  class Widget
    constructor: (@editor, @node, @data) ->
      @clean_html = @node.outerHTML()

    get_data: ->
      # This should be completed for each subclass

    render: ->
      # This should be completed for each subclass


  class Container extends Widget
    constructor: (@editor, @node, @data) ->
      super
      @block_options = []
      @block_options_by_type = {}

      @node.widgets().filter(container_nodes).each(build_options)
      @node.empty()

      if spec.data
        for i in spec.data
          type = spec.data[i].type
          temp = $(block_options_by_type[type])
          @node.append(temp)
          @editor.editor_for_node(temp, spec.data['i'].data)
      else
        temp = $(block_options[0].html)
        @node.append(temp)
        @editor.editor_for_node(temp, null)

      select = $('<select>')

      for temp, i in block_options
        option = $('<option>')
        option.attr('value', i)
        option.text(temp.label)
        select.append(option)

      handler = $('<div class="ui-widget-header ui-helper-clearfix ui-corner-all" style="z-index: 9999; margin: 0 0 10px; padding: 2px;"><span class="add ui-corner-all"><span class="ui-icon ui-icon-plus"></span></span></div>')
      handler.prepend(select)
      @node.append(handler)

      @node.sortable
        handle: 'span.move'
        scroll: true
        cursorAt: 'bottom'
        tolerance: 'pointer'
        containment: 'parent'
        items: ':widget'

      handler.on 'click', 'span.add', (event) ->
        event.preventDefault()
        new_node = $(block_options[select.get(0).value.html])
        new_node.data 'widget', new Block(new_node, null, @editor)
        new_node.hide()
        $(@).parent().before(new_node)
        new_node.fadeIn(400)

    get_data: ->
      @node.widgets().map i, elem =>
        @editor.data_for_node $(elem)

    render: ->
      container = $(@clean_html).empty()

      @node.widgets().each (i, elem) =>
        container.append(@editor.render_node($(elem)))

      return container or null

    build_options: (i, elem) ->
      $elem = $(elem)

      html = $('<div />').append($elem.clone()).remove().html()
      label = $elem.attr('m:label')

      block_options_by_type[label] = html

      block_options[i]
        label: label
        html: html

    container_nodes: (elem) ->
      $(elem).attr('m_widget') isnt 'container'


  class Block extends Widget
    constructor: (@editor, @node, @data) ->
      super
      temp = @node.widgets()

      temp.each (i, elem) =>
        @editor.editor_for_node $(elem), if @data then @data[i] else null

      handler = $('<div class="ui-widget-header ui-helper-clearfix ui-corner-all" style="z-index: 9999; position: absolute; top: -2px; right: -2px; width: 32px; height: 16px; padding: 2px;"><span class="move ui-corner-all"><span class="ui-icon ui-icon-arrow-4">Move</span></span><span class="delete ui-corner-all"><span class="ui-icon ui-icon-trash">Remove</span></span></div>');
      @node.prepend(handler)
      @node.css
        position: 'relative'

      handler.hide()

      @node.on 'hover', (event) =>
        if event.type is 'mouseenter'
          handler.show()
        else
          handler.hide()

      @node.on 'click', (event) =>
        event.preventDefault()
        event.stopPropagation()

      handler.on 'click', 'span.delete', (event) =>
        event.preventDefault()
        @node.fadeOut 400, =>
          @node.remove()

    get_data: ->
      temp = @node.widgets()
      result =
        type: @node.attr('m:label')
        data: []

      temp.each (i, elem) =>
        result['data'].push(@editor.data_for_node($(elem)))

      return result

    render: ->
      duplicate = $(@clean_html)
      @node.widgets().each (i, elem) =>
        html = @editor.render_node($(elem))
        duplicate.widgets().eq(i).replaceWith(html)

      return duplicate


  class DialogWidget extends Widget
    @fields: {}

    constructor: (@editor, @node, @data) ->
      @title = 'Dialog'

      @node.on 'click', (event) =>
        event.preventDefault()
        event.stopProgagation()

        container = $('<div id="monster-dialog-container"></div>')
        @prepare(container)

        container.dialog
          title: @get_title()
          modal: true
          buttons:
            Ok: (event) ->
              @write(container)
              $(event.target).dialog "close"
            Cancel: (event) ->
              $(event.target).dialog "close"
      @init()

    prepare: (container) ->
      for key in @fields
        if @fields.hasOwnProperty key
          field_node = @fields[key].prepare()
          field_node_wrapped = $('<div class="dialog-field" />').append(field_node)
          container.append(field_node_wrapped)

    init: ->
      if @data
        for key in @fields
          if @fields.hasOwnProperty key
            @fields[key].set_value(@data[@fields[key].data_name])

    write: ->
      for key in @fields
        if @fields.hasOwnProperty key
          @fields[key].write()

    get_title: ->
      return @title

    render: ->
      return @node.outerHTML()


  class LinkedLine extends DialogWidget
    @title = 'Linked Image'
    @fields:
      text: new fields.TextField
        verbose_name: "Text"
        callbacks: [
          -> @node.html()
          (data) -> @node.html(data)
        ]
        data_name: "text"
      href: new fields.TextField
        verbose_name: "Link URL"
        callbacks: [
          -> @node.attr('href')
          (data) -> @node.attr('href', data)
        ]
        data_name: 'href'
      title: fields.TextField
        verbose_name: "Link Title"
        callbacks: [
          -> @node.attr("title")
          (data) -> @node.attr('title', data)
        ]
        data_name: "title"


  class LinkedImage extends DialogWidget
    @title: 'Linked Image'
    @fields:
      src: new fields.ImageField
        verbose_name: "Image"
        callbacks: [
          -> @node.find('img').attr('src')
          (data) -> @node.find('img').attr('src', data)
        ]
        data_name: "src"
      alt: new fields.TextField
        verbose_name: "Alt Text"
        callbacks: [
          -> @node.find('img').attr('alt')
          (data) -> @node.find('img').attr('alt', data)
        ]
        data_name: 'alt'
      href: new fields.TextField
        verbose_name: "Link URL"
        callbacks: [
          -> @node.attr('href')
          (data) -> @node.attr('href', data)
        ]
        data_name: 'href'
      title: fields.TextField
        verbose_name: "Link Title"
        callbacks: [
          -> @node.attr("title")
          (data) -> @node.attr('title', data)
        ]
        data_name: "title"


  class Line extends Widget
    constructor: (@editor, @node, @data) ->
      super
      @node.html(@data) if @data
      @node.editable(
        (value, settings) -> return value
        ->
      )

    get_data: ->
      @node.html()

    render: ->
      @node.outerHTML()


  return {
    Container: Container
    Block: Block
    DialogWidget: DialogWidget
    LinkedLine: LinkedLine
    LinkedImage: LinkedImage
    Line: Line
  }