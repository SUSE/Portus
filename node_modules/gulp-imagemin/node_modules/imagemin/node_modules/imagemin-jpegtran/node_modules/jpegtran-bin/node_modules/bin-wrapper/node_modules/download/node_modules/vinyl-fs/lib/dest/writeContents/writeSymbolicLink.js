'use strict';

var fs = require('graceful-fs');

function writeSymbolicLink(writePath, file, cb) {
  fs.symlink(file.symlink, writePath, function (err) {
    if (err && err.code !== 'EEXIST') {
      return cb(err);
    }

    cb(null, file);
  });
}

module.exports = writeSymbolicLink;
