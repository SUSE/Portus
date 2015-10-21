# strip-debug [![Build Status](https://travis-ci.org/sindresorhus/strip-debug.svg?branch=master)](https://travis-ci.org/sindresorhus/strip-debug)

> Strip `console`, `alert`, and `debugger` statements from JavaScript code

Useful for making sure you didn't leave any logging in production code.

Also available as [gulp](https://github.com/sindresorhus/gulp-strip-debug)/[grunt](https://github.com/sindresorhus/grunt-strip-debug)/[broccoli](https://github.com/sindresorhus/broccoli-strip-debug) plugins.


## Usage

```sh
$ npm install --save strip-debug
```

```js
var stripDebug = require('strip-debug');

stripDebug('function foo(){console.log("foo");alert("foo");debugger;}').toString();
//=> function foo(){void 0;void 0;}
```


### API

## stripDebug(input)

Returns the modified [Esprima AST](http://esprima.org) which can be used to make additional modifications.

Call `.toString()` to get the stringified output.

To prevent any side-effects, `console.*`/`alert*` is replaced with `void 0` instead of being stripped.

### input

Type: `string`, `object`

Pass in a string of JavaScript code or a [Esprima compatible AST](http://esprima.org).


## CLI

```sh
$ npm install --global strip-debug
```

```sh
$ strip-debug src/app.js > dist/app.js
```

or pipe something to it:

```sh
$ echo 'function foo(){console.log("bar")}' | strip-debug
#=> function foo(){}
```


## License

MIT © [Sindre Sorhus](http://sindresorhus.com)
