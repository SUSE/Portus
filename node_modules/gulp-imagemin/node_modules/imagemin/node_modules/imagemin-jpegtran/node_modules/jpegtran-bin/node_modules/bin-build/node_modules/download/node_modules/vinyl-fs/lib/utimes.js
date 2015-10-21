'use strict';

var fs = require('graceful-fs');

function utimes(writePath, stat, cb) {
  if (stat.mtime) {
    var atime = stat.atime || new Date();

    return fs.utimes(writePath, atime, stat.mtime, cb);
  }

  cb();
}

module.exports = utimes;
