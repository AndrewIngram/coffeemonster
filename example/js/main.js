require.config({
    baseUrl: "../../src/scripts"
})

require({
    paths: {
        jqueryui: '../../lib/js/jquery-ui-1.8.20.custom.min',
        jqjson: '../../lib/js/jquery.json-2.2.min',
        cs: '../../lib/js/cs',
        CoffeeScript: '../../lib/js/CoffeeScript'
    }
}, ['cs!../../example/js/csmain']);