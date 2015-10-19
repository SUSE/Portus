/*jshint node:true */
"use strict";


var esprima = require('esprima');



// ---

// we expose the flags so other tools can tweak the values (#8)
exports.BYPASS_RECURSION = {
    root : true,
    comments : true,
    tokens : true,

    loc : true,
    range : true,

    parent : true,
    next : true,
    prev : true,

    // esprima@2.1 introduces a "handler" property on TryStatement, so we would
    // loop the same node twice (see jquery/esprima/issues/1031 and #264)`
    handler : true,

    // IMPORTANT! "value" can't be bypassed since it is used by object
    // expression
    type : true,
    raw : true,

    startToken : true,
    endToken : true
};


// ---

var _addLocInfo;

// ---


// parse string and return an augmented AST
exports.parse = function parse(source, opts){
    _addLocInfo = opts && opts.loc;
    source = source.toString();

    var ast = esprima.parse(source, {
        loc : _addLocInfo,
        range : true,
        tokens : true,
        comment : true
    });

    // we augment just root node since program is "empty"
    // can't check `ast.body.length` because it might contain just comments
    if (!ast.tokens.length && !ast.comments.length) {
        ast.depth = 0;
        ast.startToken = ast.endToken = null;
        ast.toString = _nodeProto.toString;
        return ast;
    }

    instrumentTokens(ast, source);

    // update program range since it doesn't include white spaces and comments
    // before/after the program body by default
    var lastToken = ast.tokens[ast.tokens.length - 1];
    ast.range[0] = ast.tokens[0].range[0];
    ast.range[1] = lastToken.range[1];
    if (_addLocInfo) {
        ast.loc.start.line = 0;
        ast.loc.start.column = 0;
        ast.loc.end.line = lastToken.loc.end.line;
        ast.loc.end.column = lastToken.loc.end.column;
    }

    var toString = _nodeProto.toString;
    var instrumentNodes = function(node, parent, prev, next){

        node.parent = parent;
        node.prev = prev;
        node.next = next;
        node.depth = parent? parent.depth + 1 : 0; // used later for moonwalk

        node.toString = toString;

        // we do not add nextToken and prevToken to avoid updating even more
        // references during each remove/before/after you can grab the
        // prev/next token by simply accesing the startToken.prev and
        // endToken.next
        var prevToken = prev? prev.endToken : (parent? parent.startToken : null);
        var nextToken = parent? parent.endToken : null;
        node.startToken = prevToken? getNodeStartToken(prevToken, node.range) : ast.tokens[0];
        node.endToken = nextToken? getNodeEndToken(nextToken, node.range) : ast.tokens[ast.tokens.length - 1];
    };
    recursiveWalk(ast, instrumentNodes);

    return ast;
};


var _nodeProto = {};

// get the node string
_nodeProto.toString = function(){
    var str = '';
    var token = this.startToken;
    if (!token) return str;
    do {
        str += ('raw' in token)? token.raw : token.value;
        token = token.next;
    } while (token && token !== this.endToken.next);
    return str;
};


function getNodeStartToken(token, range){
    var startRange = range[0];
    while (token){
        if (token.range[0] >= startRange) {
            return token;
        }
        token = token.next;
    }
}

function getNodeEndToken(token, range){
    var endRange = range[1];
    while (token){
        if (token.range[1] <= endRange) {
            return token;
        }
        token = token.prev;
    }
}



function getPrevToken(tokens, range){
    var result, token,
        startRange = range[0],
        n = tokens.length;
    while (n--) {
        token = tokens[n];
        if (token.range[1] <= startRange) {
            result = token;
            break;
        }
    }
    return result;
}






function instrumentTokens(ast, source){

    var tokens = ast.tokens;


    // --- inject comments into tokens list
    var comments = ast.comments;
    var comment,
        q = -1,
        nComments = comments.length;

    while (++q < nComments) {
        comment = comments[q];
        // we edit it in place since it is faster, will also affect
        comment.raw = comment.type === 'Block'? '/*'+ comment.value +'*/' : '//'+ comment.value;
        comment.type += 'Comment';

        var prevToken = getPrevToken(tokens, comment.range);
        var prevIndex = prevToken? tokens.indexOf(prevToken) : -1;
        tokens.splice(prevIndex + 1, 0, comment);
    }


    // --- inject white spaces and line breaks

    // we create a new array since it's simpler than using splice, it will
    // also avoid mistakes
    var result = [];

    // insert white spaces before start of program
    var wsTokens;
    var firstToken = ast.tokens[0];
    var raw;
    if ( firstToken.range[0] ) {
        raw = source.substring(0, firstToken.range[0]);
        result = result.concat( getWhiteSpaceTokens(raw, null) );
    }

    // insert white spaces between regular tokens
    // faster than forEach and reduce lookups
    var i = -1,
        nTokens = tokens.length,
        token, prev;
    var k, nWs;
    while (++i < nTokens) {
        token = tokens[i];
        if (i) {
            if (prev.range[1] < token.range[0]) {
                wsTokens = getWhiteSpaceTokens(source.substring(prev.range[1], token.range[0]), prev);
                // faster than concat or push.apply
                k = -1;
                nWs = wsTokens.length;
                while (++k < nWs) {
                    result.push(wsTokens[k]);
                }
            }
        }
        result.push(token);
        prev = token;
    }

    // insert white spaces after end of program
    var lastToken = ast.tokens[ast.tokens.length - 1];
    if (lastToken.range[1] < source.length) {
        wsTokens = getWhiteSpaceTokens(source.substring(lastToken.range[1], source.length), lastToken);
        k = -1;
        nWs = wsTokens.length;
        while (++k < nWs) {
            result.push(wsTokens[k]);
        }
    }

    // --- instrument tokens

    // need to come afterwards since we add line breaks and comments
    var n;
    for (i = 0, n = result.length, token; i < n; i++) {
        token = result[i];
        token.prev = i? result[i - 1] : undefined;
        token.next = result[i + 1];
        token.root = ast; // used internally
        // original indent is very important for block comments since some
        // transformations require manipulation of raw comment value
        if (
          token.type === 'BlockComment' &&
          token.prev && token.prev.type === 'WhiteSpace' &&
          (!token.prev.prev || (token.prev.prev.type === 'LineBreak'))
        ) {
          token.originalIndent = token.prev.value;
        }
    }

    ast.tokens = result;
}


function getWhiteSpaceTokens(raw, prev){
    var whiteSpaces = getWhiteSpaces(raw);

    var startRange = prev? prev.range[1] : 0;
    // line starts at 1 !!!
    var startLine, startColumn;
    if (_addLocInfo) {
        startLine = prev? prev.loc.end.line : 1;
        startColumn = prev? prev.loc.end.column : 0;
    }

    var tokens = [];
    for (var i = 0, n = whiteSpaces.length, value; i < n; i++){
        value = whiteSpaces[i];

        var wsToken = { value : value };
        var isBr = '\r\n'.indexOf(value) >= 0;
        wsToken.type = isBr? 'LineBreak' : 'WhiteSpace';
        wsToken.range = [startRange, startRange + value.length];

        if (_addLocInfo) {
            wsToken.loc = {
                start : {
                    line : startLine,
                    column : startColumn
                },
                end : {
                    line : startLine, // yes, br starts and end on same line
                    column : startColumn + value.length
                }
            };

            if (isBr) {
                // next token after a <br> always starts at zero and on next line
                startLine = wsToken.loc.end.line + 1;
                startColumn = 0;
            } else {
                startLine = wsToken.loc.end.line;
                startColumn = wsToken.loc.end.column;
            }
        }

        startRange += value.length;
        tokens.push(wsToken);
    }

    return tokens;
}


function getWhiteSpaces(source) {
    var result = [];
    var whiteSpaces = source.split('');
    var buf = '';
    for (var value, i = 0, nSpaces = whiteSpaces.length; i < nSpaces; i++) {
        value = whiteSpaces[i];
        switch(value){
            case '\n':
                if (buf === '\r') {
                    // DOS line break
                    result.push(buf + value);
                } else {
                    if (buf) {
                        result.push(buf);
                    }
                    // unix break
                    result.push(value);
                }
                buf = '';
                break;
            case '\r':
                // might be multiple consecutive Mac breaks
                if (buf) {
                    result.push(buf);
                }
                buf = value;
                break;
            default:
                if (buf === '\r') {
                    result.push(buf);
                    buf = value;
                } else {
                    // group multiple white spaces into same token
                    buf += value;
                }
        }
    }
    if (buf) {
        result.push(buf);
    }
    return result;
}



exports.walk = exports.recursive = recursiveWalk;

// heavily inspired by node-falafel
// walk nodes recursively starting from root
function recursiveWalk(node, fn, parent, prev, next){
    // sparse arrays might have `null` elements, so we skip those for now
    // see issue #15
    if ( !node || fn(node, parent, prev, next) === false ) {
        return; // stop recursion
    }

    // faster than for in
    var keys = Object.keys(node),
        child, key;

    for (var i = 0, nKeys = keys.length; i < nKeys; i++) {

        key = keys[i];
        child = node[key];

        // only need to recurse real nodes and arrays
        // ps: typeof null == 'object'
        if (!child || typeof child !== 'object' || exports.BYPASS_RECURSION[key]) {
            continue;
        }

        // inception
        if (typeof child.type === 'string') { // faster than boolean coercion
            recursiveWalk(child, fn, node);
        } else if ( typeof child.length === 'number' ) { // faster than Array.isArray and boolean coercion
            // faster than forEach
            for (var k = 0, nChilds = child.length; k < nChilds; k++) {
                recursiveWalk(child[k], fn, node, (k? child[k - 1] : undefined), child[k + 1] );
            }
        }

    }

}



// walk AST starting from leaf nodes
exports.moonwalk = function moonwalk(ast, fn){
    if (typeof ast === 'string') {
        ast = exports.parse(ast);
    }

    // we create a separate array for each depth and than we flatten it to
    // boost performance, way faster than doing an insertion sort
    var swap = [];
    recursiveWalk(ast, function(node){
        if (! swap[node.depth]) {
            swap[node.depth] = [];
        }
        swap[node.depth].push(node);
    });

    var nodes = [];
    var nDepths = swap.length, cur;
    while (cur = swap[--nDepths]) {
        for (var i = 0, n = cur.length; i < n; i++) {
            nodes.push(cur[i]);
        }
    }

    nodes.forEach(fn);
    return ast;
};

