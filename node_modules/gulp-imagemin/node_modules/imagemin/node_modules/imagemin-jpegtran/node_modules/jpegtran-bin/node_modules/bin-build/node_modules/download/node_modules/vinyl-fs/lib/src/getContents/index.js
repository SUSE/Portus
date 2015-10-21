'use strict';

var through2 = require('through2');
var readDir = require('./readDir');
var readSymbolicLink = require('./readSymbolicLink');
var bufferFile = require('./bufferFile');
var streamFile = require('./streamFile');

function getContents(opt) {
  return through2.obj(function(file, enc, cb) {
    // don't fail to read a directory
    if (file.isDirectory()) {
      return readDir(file, opt, cb);
    }

    // process symbolic links included with `followSymlinks` option
    if (file.stat && file.stat.isSymbolicLink()) {
      return readSymbolicLink(file, opt, cb);
    }

    // read and pass full contents
    if (opt.buffer !== false) {
      return bufferFile(file, opt, cb);
    }

    // dont buffer anything - just pass streams
    return streamFile(file, opt, cb);
  });
}

module.exports = getContents;
