'use strict';

var through2 = require('through2');

function filterSince(since) {
  return through2.obj(filter(since));
}

function filter(since) {
  return function(file, enc, cb) {
    if (since < file.stat.mtime) {
      return cb(null, file);
    }
    cb();
  };
}

module.exports = filterSince;
