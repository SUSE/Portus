/*global describe:false, it:false, beforeEach:false */
"use strict";

var expect = require('expect.js');
var rocambole = require('../');


describe('parse', function () {

    it('should parse string and return AST', function () {
        var ast = rocambole.parse('(function(){ return 123 })');
        expect( ast.type ).to.equal( 'Program' );
        expect( ast.body[0].type ).to.equal( 'ExpressionStatement' );
    });


    it('should include tokens before and after "program" end', function () {
        var ast = rocambole.parse('//foo\n(function(){ return 123 })\n//bar\n');
        expect( ast.startToken.value ).to.equal( 'foo' );
        expect( ast.endToken.value ).to.equal( '\n' );
        ast = rocambole.parse('\n//foo\n(function(){ return 123 })\n//dolor');
        expect( ast.startToken.value ).to.equal( '\n' );
        expect( ast.endToken.value ).to.equal( 'dolor' );
    });


    it('should work with any kind of line breaks & spaces', function () {
        var ast = rocambole.parse('\nvar n\r\n=\n10;\r\r  \t\t  \n', {loc : true});

        var br_1 = ast.startToken;
        expect( br_1.type ).to.be( 'LineBreak' );
        expect( br_1.value ).to.be( '\n' );
        expect( br_1.range ).to.eql( [0, 1] );
        expect( br_1.loc ).to.eql({
            start : {
                line : 1,
                column : 0
            },
            end : {
                line : 1,
                column : 1
            }
        });

        var ws_1 = ast.startToken.next.next;
        expect( ws_1.type ).to.be( 'WhiteSpace' );
        expect( ws_1.value ).to.be( ' ' );

        var br_2 = br_1.next.next.next.next;
        expect( br_2.type ).to.be( 'LineBreak' );
        expect( br_2.value ).to.be( '\r\n' );
        expect( br_2.range ).to.eql( [6, 8] );
        expect( br_2.loc ).to.eql({
            start : {
                line : 2,
                column : 5
            },
            end : {
                line : 2,
                column : 7
            }
        });

        // it's important to notice that esprima doesn't parse "\r" as line
        // break, so if it is not at EOF it will give conflicting "loc" info.
        var br_6 = ast.endToken;
        expect( br_6.type ).to.be( 'LineBreak' );
        expect( br_6.value ).to.be( '\n' );
        expect( br_6.range ).to.eql( [21, 22] );
        expect( br_6.loc ).to.eql({
            start : {
                line : 6,
                column : 6
            },
            end : {
                line : 6,
                column : 7
            }
        });

        var ws_2 = ast.endToken.prev;
        expect( ws_2.type ).to.be( 'WhiteSpace' );
        expect( ws_2.value ).to.be( '  \t\t  ' );
        expect( ws_2.range ).to.eql( [15, 21] );
        expect( ws_2.loc ).to.eql({
            start : {
                line : 6,
                column : 0
            },
            end : {
                line : 6,
                column : 6
            }
        });

        var br_5 = ws_2.prev;
        expect( br_5.type ).to.be( 'LineBreak' );
        expect( br_5.value ).to.be( '\r' );

        var br_4 = br_5.prev;
        expect( br_4.type ).to.be( 'LineBreak' );
        expect( br_4.value ).to.be( '\r' );
    });


    it('should not include any char that isn\'t a white space on a WhiteSpace token [issue #3]', function () {
        var ast = rocambole.parse("\n/* foo */\n/* bar */\nfunction foo(){\n  var bar = 'baz';\n\n  //foo\n  //bar\n\n  var lorem = 'ipsum';\n  return bar + lorem;\n}");
        var tk = ast.startToken;
        var nComments = 0;
        while (tk) {
            if (tk.type === 'WhiteSpace') {
                expect( tk.value ).to.match( /^[\s\t]+$/ );
            } else if (tk.type === 'LineBreak') {
                expect( tk.value ).to.equal( '\n' );
            } else if (tk.type === 'LineComment') {
                expect( tk.raw ).to.match( /^\/\/\w{3}$/ );
                nComments++;
            } else if (tk.type === 'BlockComment') {
                expect( tk.raw ).to.match( /^\/\* \w{3} \*\/$/ );
                nComments++;
            }
            tk = tk.next;
        }
        expect( nComments ).to.be( 4 );
    });


    it('should instrument object expression "value" node', function () {
        // this was a bug introduced while trying to improve performance
        var ast = rocambole.parse('amet(123, a, {flag : true});');
        var exp = ast.body[0].expression;
        expect( exp.startToken ).not.to.be(undefined);
        expect( exp.callee.startToken ).not.to.be(undefined);
        expect( exp['arguments'][0].startToken ).not.to.be(undefined);
        expect( exp['arguments'][1].startToken ).not.to.be(undefined);
        expect( exp['arguments'][2].startToken ).not.to.be(undefined);
        expect( exp['arguments'][2].properties[0].startToken ).not.to.be(undefined);
        expect( exp['arguments'][2].properties[0].key.startToken ).not.to.be(undefined);
        expect( exp['arguments'][2].properties[0].value.startToken ).not.to.be(undefined);
    });



    describe('Node', function () {

        var ast, program, expressionStatement,
            fnExpression, block, returnStatement;

        beforeEach(function(){
            ast                 = rocambole.parse('/* block */\n(function(){\n return 123; // line\n})');
            program             = ast;
            expressionStatement = ast.body[0];
            fnExpression        = expressionStatement.expression;
            block               = fnExpression.body;
            returnStatement     = block.body[0];
        });

        describe('node.parent', function () {
            it('should add reference to parent node', function () {
                expect( program.parent ).to.equal( undefined );
                expect( expressionStatement.parent ).to.equal( program );
                expect( fnExpression.parent ).to.equal( expressionStatement );
                expect( block.parent ).to.equal( fnExpression );
            });
        });


        describe('node.toString()', function(){
            it('should return the node source', function () {
                expect( returnStatement.type ).to.equal( 'ReturnStatement' );
                expect( returnStatement.toString() ).to.equal( 'return 123;' );
            });
            it('should use raw value of comments', function () {
                expect( block.toString() ).to.equal( '{\n return 123; // line\n}' );
            });
            it('should use raw value of comments', function () {
                expect( ast.toString() ).to.equal( '/* block */\n(function(){\n return 123; // line\n})' );
            });
        });


        describe('depth', function () {
            it('should add depth property to nodes', function () {
                expect( program.depth ).to.equal( 0 );
                expect( expressionStatement.depth ).to.equal( 1 );
                expect( fnExpression.depth ).to.equal( 2 );
                expect( block.depth ).to.equal( 3 );
                expect( returnStatement.depth ).to.equal( 4 );
            });
        });


        describe('node.endToken', function () {
            it('should return last token inside node', function () {
                expect( program.endToken.value ).to.equal( ')' );
                expect( expressionStatement.endToken.value ).to.equal( ')' );
                expect( fnExpression.endToken.value ).to.equal( '}' );
                expect( block.endToken.value ).to.equal( '}' );
                expect( returnStatement.endToken.value ).to.equal( ';' );
            });

            it('should capture end token properly', function () {
                var ast = rocambole.parse('[1,2,[3,4,[5,6,[7,8,9]]]];');
                var exp = ast.body[0].expression;
                expect( exp.endToken.value ).to.equal( ']' );
                expect( exp.elements[0].value ).to.equal( 1 );
                expect( exp.elements[0].startToken.value ).to.equal( '1' );
                expect( exp.elements[0].endToken.value ).to.equal( '1' );
            });
        });


        describe('node.startToken', function () {
            it('should return first token inside node', function () {
                expect( program.startToken.value ).to.equal( ' block ' );
                expect( expressionStatement.startToken.value ).to.equal( '(' );
                expect( fnExpression.startToken.value ).to.equal( 'function' );
                expect( block.startToken.value ).to.equal( '{' );
                expect( returnStatement.startToken.value ).to.equal( 'return' );
            });
        });


        describe('Node.next & Node.prev', function () {
            it('should return reference to previous and next nodes', function () {
                var ast = rocambole.parse("\n/* foo */\n/* bar */\nfunction foo(){\n  var bar = 'baz';\n  var lorem = 'ipsum';\n  return bar + lorem;\n}");
                var block = ast.body[0].body.body;
                var firstNode = block[0];
                var secondNode = block[1];
                var lastNode = block[2];
                expect( firstNode.prev ).to.equal( undefined );
                expect( firstNode.next ).to.equal( secondNode );
                expect( secondNode.prev ).to.equal( firstNode );
                expect( secondNode.next ).to.equal( lastNode );
                expect( lastNode.prev ).to.equal( secondNode );
                expect( lastNode.next ).to.equal( undefined );
            });
        });

    });


    describe('Token', function () {

        it('should instrument tokens', function () {
            var ast = rocambole.parse('function foo(){ return "bar"; }');
            var tokens = ast.tokens;

            expect( tokens[0].prev ).to.be(undefined);
            expect( tokens[0].next ).to.be( tokens[1] );
            expect( tokens[1].prev ).to.be( tokens[0] );
            expect( tokens[1].next ).to.be( tokens[2] );
        });

        it('should add range and loc info to comment tokens', function () {
            var ast = rocambole.parse('\n/* foo\n  bar\n*/\nfunction foo(){ return "bar"; }\n// end', {loc:true});
            var blockComment = ast.startToken.next;
            expect( blockComment.range ).to.eql( [1, 16] );
            expect( blockComment.loc ).to.eql({
                start : {
                    line : 2,
                    column : 0
                },
                end : {
                    line : 4,
                    column : 2
                }
            });
            var lineComment = ast.endToken;
            expect( lineComment.range ).to.eql( [49, 55] );
            expect( lineComment.loc ).to.eql({
                start : {
                    line : 6,
                    column : 0
                },
                end : {
                    line : 6,
                    column : 6
                }
            });
        });

        it('should add originalIndent info to block comments', function () {
            var ast = rocambole.parse('  /* foo */\n\t\t// bar');
            expect( ast.startToken.next.originalIndent ).to.be('  ');
        });

        it('should not add originalIndent info to line comments', function () {
            var ast = rocambole.parse('  /* foo */\n\t\t// bar');
            expect( ast.endToken.originalIndent ).to.be(undefined);
        });

        it('should not add as originalIndent if prev token is not white space', function () {
            var ast = rocambole.parse('lorem;/* foo */\n\t\t// bar');
            expect( ast.startToken.next.next.originalIndent ).to.be(undefined);
        });

        it('should not add as originalIndent if prev token is not on a new line', function () {
            var ast = rocambole.parse('lorem;  /* foo */\n\t\t// bar');
            expect( ast.startToken.next.next.next.originalIndent ).to.be(undefined);
        });

        it('should add as originalIndent if on a new line', function () {
            var ast = rocambole.parse('lorem;\n  /* foo */\n\t\t// bar');
            expect( ast.startToken.next.next.next.next.originalIndent ).to.be('  ');
        });
    });


    describe('export BYPASS_RECURSION', function () {
        it('should export BYPASS_RECURSION', function () {
            expect( rocambole.BYPASS_RECURSION.root ).to.be(true);
        });
    });


    describe('empty program', function () {
        it('should not throw if program is empty', function () {
            expect(function(){
                rocambole.parse('');
            }).not.throwError();
        });
        it('should return augmented AST', function () {
            var ast = rocambole.parse('');
            expect(ast).to.eql({
                type: 'Program',
                body: [],
                range: [0,0],
                comments: [],
                tokens: [],
                // we check toString behavior later
                toString: ast.toString,
                startToken: null,
                endToken: null,
                depth: 0
            });
        });
        it('toString should return proper value', function() {
            var ast = rocambole.parse('');
            expect(ast.toString()).to.be('');
        });
    });


    describe('support anything that implements `toString` as input', function () {
        it('should support arrays', function () {
            var ast = rocambole.parse([1,2,3]);
            expect(ast.body[0].toString()).to.eql('1,2,3');
        });
        it('should support functions', function () {
            var ast = rocambole.parse(function doStuff(){
                doStuff(1, 2);
            });
            expect(ast.body[0].type).to.be('FunctionDeclaration');
        });
    });


    describe('sparse array', function() {
      // yes, people shold not be writting code like this, but we should not
      // bail when that happens
      it('should not fail on sparse arrays', function() {
        var ast = rocambole.parse('[,3,[,4]]');
        expect(ast.toString()).to.eql('[,3,[,4]]');
        var elements = ast.body[0].expression.elements;
        expect(elements[0]).to.be(null);
        expect(elements[1].type).to.be('Literal');
        expect(elements[1].value).to.be(3);
      });
    });

});

