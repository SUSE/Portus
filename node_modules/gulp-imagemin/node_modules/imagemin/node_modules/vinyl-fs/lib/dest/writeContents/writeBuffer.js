'use strict';

var fs = require('graceful-fs');

function writeBuffer(writePath, file, cb) {
  var opt = {
    mode: file.stat.mode,
    flag: file.flag
  };

  fs.writeFile(writePath, file.contents, opt, cb);
}

module.exports = writeBuffer;
