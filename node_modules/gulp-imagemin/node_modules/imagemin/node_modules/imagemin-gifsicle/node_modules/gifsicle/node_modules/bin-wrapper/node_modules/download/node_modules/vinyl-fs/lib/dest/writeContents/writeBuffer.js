'use strict';

var fs = require('graceful-fs');

var utimes = require('../../utimes');

function writeBuffer(writePath, file, cb) {
  var stat = file.stat;

  var opt = {
    mode: stat.mode,
    flag: file.flag
  };

  fs.writeFile(writePath, file.contents, opt, function(error) {
    if (error) {
      return cb(error);
    }

    utimes(writePath, stat, cb);
  });
}

module.exports = writeBuffer;
