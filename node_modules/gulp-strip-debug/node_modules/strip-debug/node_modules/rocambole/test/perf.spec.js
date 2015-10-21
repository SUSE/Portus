/*global describe:false, it:false */
"use strict";

var expect = require('expect.js');
var rocambole = require('../');

var _fs = require('fs');

// since it takes a long time to instrument jQuery we avoid doing it multiple
// times and cache the result
var _jqueryAST;


describe('performance', function () {

    describe('rocambole.parse', function () {
        it('should be fast :P', function () {
            var file = _fs.readFileSync( __dirname +'/files/crossroads.js', 'utf-8');
            var startTime = process.hrtime();
            var ast = rocambole.parse(file);
            var diff = process.hrtime(startTime);
            expect( diff[0] ).to.be.below( 300 );
            expect( ast.startToken ).not.to.be( undefined );
        });

        it('should not take forever to instrument jQuery', function () {
            var file = _fs.readFileSync( __dirname +'/files/jquery.js', 'utf-8');
            var startTime = process.hrtime();
            var ast = rocambole.parse(file);
            var diff = process.hrtime(startTime);
            expect( diff[0] ).to.be.below( 10000 );
            expect( ast.startToken ).not.to.be( undefined );
            _jqueryAST = ast;
        });
    });

    describe('rocambole.moonwalk', function () {
        it('should not take forever to loop over jQuery nodes', function () {
            if (! _jqueryAST) {
                var file = _fs.readFileSync( __dirname +'/files/jquery.js', 'utf-8');
                _jqueryAST = rocambole.parse(file);
            }
            var startTime = process.hrtime();
            var count = 0;
            rocambole.moonwalk(_jqueryAST, function(node){
                if (!node) throw new Error('node should not be undefined');
                count += 1;
            });
            var diff = process.hrtime(startTime);
            expect( diff[0] ).to.be.below( 200 );
            expect( count ).to.be.above( 20000 );
        });
    });

});




