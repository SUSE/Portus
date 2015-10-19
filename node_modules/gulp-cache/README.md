# gulp-cache

[![NPM version](https://img.shields.io/npm/v/gulp-cache.svg)](https://www.npmjs.com/package/gulp-cache)
[![status](https://travis-ci.org/jgable/gulp-cache.svg?branch=master)](https://travis-ci.org/jgable/gulp-cache)
[![Coverage Status](https://img.shields.io/coveralls/jgable/gulp-cache.svg)](https://coveralls.io/r/jgable/gulp-cache)
[![Dependency Status](https://img.shields.io/david/jgable/gulp-cache.svg)](https://david-dm.org/jgable/gulp-cache)
[![devDependency Status](https://img.shields.io/david/dev/jgable/gulp-cache.svg)](https://david-dm.org/jgable/gulp-cache#info=devDependencies)

A temp file based caching proxy task for [gulp](http://gulpjs.com/).

## Usage

```javascript
var fs = require('fs');

var gulp = require('gulp');
var jshint = require('gulp-jshint');
var cache = require('gulp-cache');

gulp.task('lint', function() {
  gulp.src('./lib/*.js')
    .pipe(cache(jshint('.jshintrc'), {
      key: makeHashKey,
      // What on the result indicates it was successful
      success: function (jshintedFile) {
        return jshintedFile.jshint.success;
      },
      // What to store as the result of the successful action
      value: function(jshintedFile) {
        // Will be extended onto the file object on a cache hit next time task is ran
        return {
          jshint: jshintedFile.jshint
        };
      }
    }))
    .pipe(jshint.reporter('default'));
});

var jsHintVersion = '2.4.1',
  jshintOptions = fs.readFileSync('.jshintrc');
function makeHashKey(file) {
  // Key off the file contents, jshint version and options
  return [file.contents.toString('utf8'), jshintVersion, jshintOptions].join('');
}
```

## Clearing the cache

If you find yourself needing to clear the cache, there is a handy dandy `cache.clearAll()` method:

```js
var cache = require('gulp-cache');

gulp.task('clear', function (done) {
  return cache.clearAll(done);
});
```

You can then run it with `gulp clear`.

## Options

#### `fileCache`

> [Optional] Where to store the cache objects

- Defaults to `new Cache({ cacheDirName: 'gulp-cache' })`

- Create your own with `new cache.Cache({ cacheDirName: 'custom-cache' })`

#### `name`

> [Optional] The name of the bucket which stores the cached objects

- Defaults to `default`

#### `key`

> [Optional] What to use to determine the uniqueness of an input file for this task.

- Can return a string or a promise that resolves to a string.  Optionally, can accept a callback parameter for idiomatic node style asynchronous operations.  

- The result of this method is converted to a unique MD5 hash automatically; no need to do this yourself.

- Defaults to `file.contents` if a Buffer, or `undefined` if a Stream.

#### `success`

> [Optional] How to determine if the resulting file was successful.

- Must return a truthy value that is used to determine whether to cache the result of the task.

- Defaults to true, so any task results will be cached.

#### `value`

> [Optional] What to store as the cached result of the task.

- Can be a function that returns an Object or a promise that resolves to an Object.  Optionally, can accept a callback for idiomatic node style asynchronous operations.

- Can also be set to a string that will be picked (using `_.pick`) of the task result file.

- The result of this method is run through `JSON.stringify` and stored in a temp file for later retrieval.

- Defaults to `'contents'` which will grab the resulting file.contents and store them as a string.

## License

[The MIT License (MIT)](./LICENSE)

Copyright (c) 2014 - 2015 [Jacob Gable](http://jacobgable.com)
