/* jshint strict:true */
/* global describe, it, expect, beforeEach */
"use strict";

// ---


var rocambole = require('rocambole');

var _find = require('../find');
var findInBetween = _find.findInBetween;
var findInBetweenFromEnd = _find.findInBetweenFromEnd;


// ---


describe('find', function () {


  describe('findInBetween', function () {

    var ast = rocambole.parse('var foo = "bar";\nfunction fn(a, b){\nreturn b? a + b : a * 2;\n}');

    it('should return first token inside range by value', function () {
      var tk = findInBetween(ast.startToken, ast.endToken, 'a');
      expect( tk.type ).toBe( 'Identifier' );
      expect( tk.value ).toBe( 'a' );
      expect( tk.prev.value ).toBe( '(' );
    });

    it('should return first token inside range by Type', function () {
      var tk = findInBetween(ast.startToken, ast.endToken, 'Punctuator');
      expect( tk.value ).toBe( '=' );
    });

    it('should return first token that passes truth test', function () {
      var tk = findInBetween(ast.startToken, ast.endToken, function(val){
        return val.type === 'Punctuator' && val.prev.prev.value !== 'foo';
      });
      expect( tk.value ).toBe(';');
    });

    it('shold return first token that matches any array items values', function () {
      var tk = findInBetween(ast.startToken, ast.endToken, ['?', 'return']);
      expect( tk.type ).toBe( 'Keyword' );
    });

    it('shold return first token that matches any array items types', function () {
      var tk = findInBetween(ast.startToken, ast.endToken, ['Keyword', 'Identifier']);
      expect( tk.value ).toBe( 'var' );
    });

  });


  describe('findInBetweenFromEnd', function () {

    var ast = rocambole.parse('var foo = "bar";\nfunction fn(a, b){\nreturn b? a + b : a * 2;\n}');

    it('should return first match from end by "type"', function () {
      var tk = findInBetweenFromEnd(ast.startToken, ast.endToken, 'Keyword');
      expect( tk.value ).toBe( 'return' );
    });

    it('should return first match from end by "value"', function () {
      var tk = findInBetweenFromEnd(ast.startToken, ast.endToken, 'a');
      expect( tk.prev.prev.value ).toBe( ':' );
    });


  });


});

