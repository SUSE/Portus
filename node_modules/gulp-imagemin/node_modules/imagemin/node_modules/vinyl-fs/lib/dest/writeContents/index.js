'use strict';

var fs = require('fs');
var writeDir = require('./writeDir');
var writeStream = require('./writeStream');
var writeBuffer = require('./writeBuffer');

function writeContents(writePath, file, cb) {
  // if directory then mkdirp it
  if (file.isDirectory()) {
    return writeDir(writePath, file, written);
  }

  // stream it to disk yo
  if (file.isStream()) {
    return writeStream(writePath, file, written);
  }

  // write it like normal
  if (file.isBuffer()) {
    return writeBuffer(writePath, file, written);
  }

  // if no contents then do nothing
  if (file.isNull()) {
    return complete();
  }

  function complete(err) {
    cb(err, file);
  }

  function written(err) {

    if (isErrorFatal(err)) {
      return complete(err);
    }

    if (!file.stat || typeof file.stat.mode !== 'number') {
      return complete();
    }

    fs.stat(writePath, function(err, st) {
      if (err) {
        return complete(err);
      }
      // octal 7777 = decimal 4095
      var currentMode = (st.mode & 4095);
      if (currentMode === file.stat.mode) {
        return complete();
      }
      fs.chmod(writePath, file.stat.mode, complete);
    });
  }

  function isErrorFatal(err) {
    if (!err) {
      return false;
    }

    // Handle scenario for file overwrite failures.
    else if (err.code === 'EEXIST' && file.flag === 'wx') {
      return false;   // "These aren't the droids you're looking for"
    }

    // Otherwise, this is a fatal error
    return true;
  }
}

module.exports = writeContents;
