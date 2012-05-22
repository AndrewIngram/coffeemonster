define ['jquery', 'jqueryui', 'jqjson', 'jquery.monster', 'cs!monster'], ($, jqui, jqjson, jqm, monster) ->
  $(document).ready ->
    node = $('#contents-primary');
    data = []
    editor = new monster.Editor(node, data)

    $('button#data').click ->
      console.log editor.get_data()

    $('button#render').click ->
      editor.render (html) ->
        $('#render-target').html(html)
