'use strict';

var fs = require('graceful-fs');

var streamFile = require('../../src/getContents/streamFile');
var utimes     = require('../../utimes');

function writeStream(writePath, file, cb) {
  var stat = file.stat;

  var opt = {
    mode: stat.mode,
    flag: file.flag
  };

  var outStream = fs.createWriteStream(writePath, opt);

  file.contents.once('error', complete);
  outStream.once('error', complete);
  outStream.once('finish', success);

  file.contents.pipe(outStream);

  function success() {
    streamFile(file, {}, function(error) {
      if (error) {
        return complete(error);
      }

      utimes(writePath, stat, complete);
    });
  }

  // cleanup
  function complete(err) {
    file.contents.removeListener('error', cb);
    outStream.removeListener('error', cb);
    outStream.removeListener('finish', success);
    cb(err);
  }
}

module.exports = writeStream;
