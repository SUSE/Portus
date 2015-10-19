'use strict';

var streamFile = require('../../src/getContents/streamFile');
var fs = require('graceful-fs');

function writeStream(writePath, file, cb) {
  var opt = {
    mode: file.stat.mode,
    flag: file.flag
  };

  var outStream = fs.createWriteStream(writePath, opt);

  file.contents.once('error', complete);
  outStream.once('error', complete);
  outStream.once('finish', success);

  file.contents.pipe(outStream);

  function success() {
    streamFile(file, complete);
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
