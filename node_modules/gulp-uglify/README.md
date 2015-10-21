# gulp-uglify [![Build Status](https://img.shields.io/travis/terinjokes/gulp-uglify/master.svg)](https://travis-ci.org/terinjokes/gulp-uglify) [![](https://img.shields.io/npm/dm/gulp-uglify.svg)](https://www.npmjs.org/package/gulp-uglify) [![](https://img.shields.io/npm/v/gulp-uglify.svg)](https://www.npmjs.org/package/gulp-uglify) [![](https://img.shields.io/coveralls/terinjokes/gulp-uglify/master.svg)](https://coveralls.io/github/terinjokes/gulp-uglify)

> Minify JavaScript with UglifyJS2.

## Installation

Install package with NPM and add it to your development dependencies:

`npm install --save-dev gulp-uglify`

## Usage

```javascript
var uglify = require('gulp-uglify');

gulp.task('compress', function() {
  return gulp.src('lib/*.js')
    .pipe(uglify())
    .pipe(gulp.dest('dist'));
});
```

## Options

- `mangle`

	Pass `false` to skip mangling names.

- `output`

	Pass an object if you wish to specify additional [output
	options](http://lisperator.net/uglifyjs/codegen). The defaults are
	optimized for best compression.

- `compress`

	Pass an object to specify custom [compressor
	options](http://lisperator.net/uglifyjs/compress). Pass `false` to skip
	compression completely.

- `preserveComments`

	A convenience option for `options.output.comments`. Defaults to preserving no
	comments.

	- `all`

		Preserve all comments in code blocks

	- `license`

		Attempts to preserve comments that likely contain licensing information,
		even if the comment does not have directives such as `@license` or `/*!`.

		Implemented via the [`uglify-save-license`](https://github.com/shinnn/uglify-save-license)
		module, this option preserves a comment if one of the following is true:

		1. The comment is in the *first* line of a file
		2. A regular expression matches the string of the comment.
				For example: `MIT`, `@license`, or `Copyright`.
		3. There is a comment at the *previous* line, and it matches 1, 2, or 3.

	- `function`

		Specify your own comment preservation function. You will be passed the
		current node and the current comment and are expected to return either
		`true` or `false`.

	- `some` (deprecated)

		Preserve comments that start with a bang (`!`) or include a Closure Compiler
		directive (`@preserve`, `@license`, `@cc_on`).
		Deprecated in favor of the `license` option, documented above.

You can also pass the `uglify` function any of the options [listed
here](https://github.com/mishoo/UglifyJS2#the-simple-way) to modify
UglifyJS's behavior.

## Errors

`gulp-uglify` emits an 'error' event if it is unable to minify a specific file.
Wherever possible, the PluginError object will contain the following properties:

- `fileName`
- `lineNumber`
- `message`

To handle errors across your entire pipeline, see the
[gulp](https://github.com/gulpjs/gulp/blob/master/docs/recipes/combining-streams-to-handle-errors.md#combining-streams-to-handle-errors) documentation.
