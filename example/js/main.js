require.config({
    baseUrl: "../../src/scripts"
})

require({
    paths: {
        cs: '../../lib/js/cs',
        CoffeeScript: '../../lib/js/CoffeeScript'
    }
}, ['cs!../../example/js/csmain']);