"use strict";

// we run mocha manually otherwise istanbul coverage won't work
// run `npm test --coverage` to generate coverage report

var Mocha = require('mocha');

var opts = {
    ui : 'bdd',
    reporter : (process.env.REPORTER || 'spec'),
    grep : process.env.GREP
};

// we use the dot reporter on travis since it works better
if (process.env.TRAVIS) {
    opts.reporter = 'dot';
}

var m = new Mocha(opts);

if (process.env.INVERT) {
    m.invert();
}

m.addFile('test/parse.spec.js');
m.addFile('test/moonwalk.spec.js');
m.addFile('test/perf.spec.js');

m.run(function(err){
    var exitCode = err? 1 : 0;
    process.exit(exitCode);
});

