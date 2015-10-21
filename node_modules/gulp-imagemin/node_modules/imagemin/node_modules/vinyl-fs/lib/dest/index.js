'use strict';

var through2 = require('through2');
var prepareWrite = require('../prepareWrite');
var writeContents = require('./writeContents');

function dest(outFolder, opt) {
  function saveFile(file, enc, cb) {
    prepareWrite(outFolder, file, opt, function(err, writePath) {
      if (err) {
        return cb(err);
      }
      writeContents(writePath, file, cb);
    });
  }

  var stream = through2.obj(saveFile);
  // TODO: option for either backpressure or lossy
  stream.resume();
  return stream;
}

module.exports = dest;
