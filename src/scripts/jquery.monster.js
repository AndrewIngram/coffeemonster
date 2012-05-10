$.extend($.expr[':'],{
    widget: function(elem, index, match, array){

        var $elem = $(elem);

        if ($elem.attr('m:widget')){
            return true;
        }
        return false;
    }
});

$.fn.extend({
    widgets : function() {
        var node = this;
        var temp = node.find(':widget');

        var result = temp.filter(function(i){
            var parents = $(this).parents(':widget');

            if (parents.length > 0) {
                var index = parents.index(node);

                if (index === 0) { return true; }
                return false;
            }
            return true;
        });

        return result;
    },
    outerHTML: function(s) {
        return (s) ? this.before(s).remove() : $('<div>').append(this.eq(0).clone()).html();
    },
    getCSS : function() {
        if (arguments.length) {
            return $.fn.css.apply(this, arguments);
        }
        var attr = ['font-family','font-size','font-weight','font-style','color',
            'text-transform','text-decoration','letter-spacing','word-spacing',
            'line-height','text-align','vertical-align','direction','background-color',
            'background-image','background-repeat','background-position',
            'background-attachment','opacity','width','height','top','right','bottom',
            'left','margin-top','margin-right','margin-bottom','margin-left',
            'padding-top','padding-right','padding-bottom','padding-left',
            'border-top-width','border-right-width','border-bottom-width',
            'border-left-width','border-top-color','border-right-color',
            'border-bottom-color','border-left-color','border-top-style',
            'border-right-style','border-bottom-style','border-left-style','position',
            'display','visibility','z-index','overflow-x','overflow-y','white-space',
            'clip','float','clear','cursor','list-style-image','list-style-position',
            'list-style-type','marker-offset'];
        var len = attr.length, obj = {};
        for (var i = 0; i < len; i++) {
            obj[attr[i]] = $.fn.css.call(this, attr[i]);
        }
        return obj;
    },
    getStyleString : function() {
        var map = $.fn.getCSS.call(this);

        var result = '';

        for (var entry in map) {
            if (map.hasOwnProperty(entry)){
                var val = map[entry];

                var temp = entry + ': ' + val + ';\n';
                result += temp;
            }
        }

        return result;
    }
});