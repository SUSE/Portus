'use strict';

var assign = require('object-assign');
var through = require('through2');
var gs = require('glob-stream');
var File = require('vinyl');
var duplexify = require('duplexify');
var merge = require('merge-stream');
var sourcemaps = require('gulp-sourcemaps');
var filterSince = require('../filterSince');
var isValidGlob = require('is-valid-glob');

var getContents = require('./getContents');
var resolveSymlinks = require('./resolveSymlinks');

function createFile(globFile, enc, cb) {
  cb(null, new File(globFile));
}

function src(glob, opt) {
  var options = assign({
    read: true,
    buffer: true,
    stripBOM: true,
    sourcemaps: false,
    passthrough: false,
    followSymlinks: true
  }, opt);

  var inputPass;

  if (!isValidGlob(glob)) {
    throw new Error('Invalid glob argument: ' + glob);
  }

  var globStream = gs.create(glob, options);

  var outputStream = globStream
    .pipe(resolveSymlinks(options))
    .pipe(through.obj(createFile));

  if (options.since != null) {
    outputStream = outputStream
      .pipe(filterSince(options.since));
  }

  if (options.read !== false) {
    outputStream = outputStream
      .pipe(getContents(options));
  }

  if (options.passthrough === true) {
    inputPass = through.obj();
    outputStream = duplexify.obj(inputPass, merge(outputStream, inputPass));
  }
  if (options.sourcemaps === true) {
    outputStream = outputStream
      .pipe(sourcemaps.init({loadMaps: true}));
  }
  globStream.on('error', outputStream.emit.bind(outputStream, 'error'));
  return outputStream;
}

module.exports = src;
