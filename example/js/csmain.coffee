define ['jquery', 'jquery.monster', 'cs!monster'], ($, jqm, monster) ->
  $(document).ready ->
    node = $('#contents-primary');
    data = ["Page Title",{"src":"http://dummyimage.com/960x100","alt":"","href":"http://www.google.com/","title":""},"Lipsum.org",[{"type":"Block 1","data":["Subheading",{"src":"http://dummyimage.com/200x100","alt":"","href":"#","title":""}]},{"type":"Block 1","data":["Heading 2",{"src":"http://dummyimage.com/100x100","alt":"","href":"#","title":""}]},{"type":"Block 2","data":["Heading 2",[{"type":"Subblock 1","data":["Heading 2",{"src":"http://dummyimage.com/50x50","alt":"","href":"#","title":""}]},{"type":"Subblock 1","data":["Heading 2",{"src":"http://dummyimage.com/50x50","alt":"","href":"#","title":""}]}]]}]];

    console.log(monster)

    editor = new monster.Editor(node, data)

    $('button#data').click ->
      console.log($.toJSON(editor.get_data()))

    $('button#render').click ->
      editor.render ->
        $('#render-target').html(node)
