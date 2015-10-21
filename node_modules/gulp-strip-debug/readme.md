# [gulp](https://github.com/wearefractal/gulp)-strip-debug [![Build Status](https://travis-ci.org/sindresorhus/gulp-strip-debug.svg?branch=master)](https://travis-ci.org/sindresorhus/gulp-strip-debug)

> Strip `console`, `alert`, and `debugger` statements from JavaScript code with [strip-debug](https://github.com/sindresorhus/strip-debug)


## Install

```sh
$ npm install --save-dev gulp-strip-debug
```


## Usage

```js
var gulp = require('gulp');
var stripDebug = require('gulp-strip-debug');

gulp.task('default', function () {
	return gulp.src('src/app.js')
		.pipe(stripDebug())
		.pipe(gulp.dest('dist'));
});
```


## License

MIT © [Sindre Sorhus](http://sindresorhus.com)
