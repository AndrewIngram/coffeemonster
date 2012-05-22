define ['jquery', '../../lib/js/jquery.jeditable', '../../lib/js/showdown', 'cs!fields'], ($, jeditable, showdown, fields) ->
  class Widget
    constructor: (@editor, @node, @data) ->
      @clean_html = @node.outerHTML()

    get_data: ->
      @node.html()

    render: ->
      @node.outerHTML()


  class Container extends Widget
    constructor: (@editor, @node, @data) ->
      super

      @block_options = []
      @block_options_by_type = {}

      @node.widgets().filter(@container_nodes).each(@build_options)
      @node.empty()

      if @data
        for val in @data
          temp = $(@block_options_by_type[val.type])
          @node.append(temp)
          @editor.editor_for_node(temp, val.data)
      else
        temp = $(@block_options[0].html)
        @node.append(temp)
        @editor.editor_for_node(temp, null)

      select = $('<select style="float: left">')

      for temp, i in @block_options
        option = $('<option>')
        option.attr('value', i)
        option.text(temp.label)
        select.append(option)

      handler = $("""
        <div class="ui-widget-header ui-helper-clearfix ui-corner-all" style="z-index: 9999; margin: 0 0 10px; padding: 2px;">
          <span class="add ui-corner-all">
            <span class="ui-icon ui-icon-plus"></span>
          </span>
        </div>""")
      handler.prepend(select)
      @node.append(handler)

      @node.sortable
        handle: 'span.move'
        scroll: true
        #cursorAt: 'bottom'
        tolerance: 'pointer'
        containment: 'parent'
        items: ':widget'
        forcePlaceholderSize: true
        placeholder: 'ui-state-highlight'

      handler.on 'click', 'span.add', (event) =>
        event.preventDefault()
        new_node = $(@block_options[select.get(0).value].html)
        new_node.data 'widget', new Block(@editor, new_node, null)
        new_node.hide()
        $(event.target).closest('.ui-widget-header').before(new_node)
        new_node.fadeIn(400)

    get_data: ->
      $.map @node.widgets(), (elem, i) =>
        @editor.data_for_node $(elem)

    render: ->
      container = $(@clean_html).empty()

      @node.widgets().each (i, elem) =>
        container.append(@editor.render_node($(elem)))

      return container or null

    build_options: (i, elem) =>
      $elem = $(elem)

      html = $('<div />').append($elem.clone()).remove().html()
      label = $elem.attr('m:label')

      @block_options_by_type[label] = html

      @block_options[i] =
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

      handler = $("""
        <div class="ui-widget-header ui-helper-clearfix ui-corner-all" style="z-index: 9999; position: absolute; top: -2px; right: -2px; width: 32px; height: 16px; padding: 2px;">
          <span class="move ui-corner-all">
            <span style="position: absolute; left: 1; top: 1;" class="ui-icon ui-icon-arrow-4">Move</span>
          </span>
          <span class="delete ui-corner-all">
            <span style="position: absolute; left: 17px; top: 1;" class="ui-icon ui-icon-trash">Remove</span>
          </span>
        </div>
      """)
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
    title: 'Dialog'

    init_fields: ->
      @fields = {}

    constructor: (@editor, @node, @data) ->
      super
      @init_fields()

      @node.on 'click', (event) =>
        event.preventDefault()
        event.stopPropagation()

        container = $('<div id="monster-dialog-container"></div>')
        @prepare(container)

        container.dialog
          title: @get_title()
          modal: true
          buttons:
            Ok: (event) =>
              @write(container)
              container.dialog "close"
            Cancel: (event) =>
              container.dialog "close"
      @init()

    prepare: (container) ->
      for name, field of @fields
        field_node = field.prepare()
        field_node_wrapped = $('<div class="dialog-field" />').append(field_node)
        container.append(field_node_wrapped)

    init: ->
      if @data
        for name, field of @fields
          field.set_value(@data[field.data_name])

    write: ->
      for name, field of @fields
          field.write()

    get_title: ->
      return @title

    get_data: ->
      result = {}
      for name, field of @fields
        result[field.data_name] = field.get_value()
      return result


  class LinkedHeading extends DialogWidget
    title: 'Linked Heading'

    init_fields: ->
      @fields =
        text: new fields.TextField
          verbose_name: "Text"
          callbacks: [
            => @node.find('a').html()
            (data) => @node.find('a').html(data)
          ]
          data_name: "text"
        href: new fields.TextField
          verbose_name: "Link URL"
          callbacks: [
            => @node.find('a').attr('href')
            (data) => @node.find('a').attr('href', data)
          ]
          data_name: 'href'
        title: new fields.TextField
          verbose_name: "Link Title"
          callbacks: [
            => @node.find('a').attr("title")
            (data) => @node.find('a').attr('title', data)
          ]
          data_name: "title"



  class LinkedImage extends DialogWidget
    title: 'Linked Image'

    init_fields: ->
      @fields =
        src: new fields.ImageField
          verbose_name: "Image"
          callbacks: [
            => @node.find('img').attr('src')
            (data) =>
              @node.find('img').attr('src', data)
          ]
          data_name: "src"
        alt: new fields.TextField
          verbose_name: "Alt Text"
          callbacks: [
            =>
              @node.find('img').attr('alt')
            (data) =>
              @node.find('img').attr('alt', data)
          ]
          data_name: 'alt'
        href: new fields.TextField
          verbose_name: "Link URL"
          callbacks: [
            => @node.attr('href')
            (data) => @node.attr('href', data)
          ]
          data_name: 'href'
        title: new fields.TextField
          verbose_name: "Link Title"
          callbacks: [
            => @node.attr("title")
            (data) => @node.attr('title', data)
          ]
          data_name: "title"


  class Line extends Widget
    constructor: (@editor, @node, @data) ->
      super
      @node.html(@data) if @data
      @node.attr('contentEditable', 'true')

      @node.editable(
        (value, settings) -> return value
        ->
      )

    get_data: ->
      @node.html()

    render: ->
      @node.outerHTML()


  class Markdown extends Widget
    constructor: (@editor, @node, @data) ->
      super
      @converter = new showdown.Showdown.converter()
      @node.html(converter.makeHtml(@data)) if @data

      @node.on 'click', (event) =>
        event.preventDefault()
        event.stopPropagation()

        container = $('<textarea>Enter text...</textarea>')
        container.text(@data)

        container.dialog
          title: 'Markdown Text'
          modal: true
          width: 640
          height: 480
          resizable: false
          draggable: false
          buttons:
            Ok: (event) =>
              @data = container.val()
              @node.html(@converter.makeHtml(@data))
              container.dialog 'close'
            Cancel: (event) =>
              container.dialog 'close'


  return {
    Container: Container
    Block: Block
    DialogWidget: DialogWidget
    LinkedHeading: LinkedHeading
    LinkedImage: LinkedImage
    Line: Line
    Markdown: Markdown
  }