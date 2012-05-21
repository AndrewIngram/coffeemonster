define ['jquery'], ($) ->
  class Field
    constructor: (params) ->
      @callbacks = params.callbacks
      @verbose_name = params.verbose_name
      @data_name = params.data_name

    get_value: ->
      @callbacks[0]()

    set_value: (data) ->
      return @callbacks[1](data)

    prepare: ->
      html = """
        <label for="dialog-field-#{ @data_name }">#{ @verbose_name }</label>
        <input name="dialog-field-#{ @data_name }"></input>
      """
      data = @get_value()
      @field_node = $(html)

      if data
        @field_node.filter('input').val(data)

      return @field_node

    write: ->
      @set_value(@field_node.filter('input').val())

  class TextField extends Field

  class ImageField extends Field
    prepare: ->
      html = """
         <label for="dialog-field-#{ @data_name }">#{ @verbose_name }</label>
         <input name="dialog-field-#{ @data_name }"></input><br/>
         <img src="" width="200" />
      """
      data = @get_value()
      @field_node = $(html)

      if data
        @field_node.filter('input').val(data)
        @field_node.filter('img').attr('src', data)

      @field_node.filter('input').on 'change', (event) =>
        @field_node.filter('img').attr('src', $(event.target).val())

  return {
    Field: Field
    TextField: TextField
    ImageField: ImageField
  }