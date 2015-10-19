'use strict';

var fs = require('fs');
var writeDir = require('./writeDir');
var writeStream = require('./writeStream');
var writeBuffer = require('./writeBuffer');
var writeSymbolicLink = require('./writeSymbolicLink');

function writeContents(writePath, file, cb) {
  // if directory then mkdirp it
  if (file.isDirectory()) {
    return writeDir(writePath, file, written);
  }

  // stream it to disk yo
  if (file.isStream()) {
    return writeStream(writePath, file, written);
  }

  // write it as a symlink
  if (file.symlink) {
    return writeSymbolicLink(writePath, file, written);
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

    if (!file.stat || typeof file.stat.mode !== 'number' || file.symlink) {
      return complete();
    }

    fs.stat(writePath, function(err, st) {
      if (err) {
        return complete(err);
      }
      var currentMode = (st.mode & parseInt('0777', 8));
      var expectedMode = (file.stat.mode & parseInt('0777', 8));
      if (currentMode === expectedMode) {
        return complete();
      }
      fs.chmod(writePath, expectedMode, complete);
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
