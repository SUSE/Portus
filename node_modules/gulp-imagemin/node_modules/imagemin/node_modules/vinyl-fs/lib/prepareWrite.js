'use strict';

var assign = require('object-assign');
var path = require('path');
var mkdirp = require('mkdirp');
var fs = require('graceful-fs');

function prepareWrite(outFolder, file, opt, cb) {
  var options = assign({
    cwd: process.cwd(),
    mode: (file.stat ? file.stat.mode : null),
    dirMode: null,
    overwrite: true
  }, opt);
  options.flag = (options.overwrite ? 'w' : 'wx');

  var cwd = path.resolve(options.cwd);

  if (typeof outFolder !== 'string' && typeof outFolder !== 'function') {
    throw new Error('Invalid output folder');
  }

  var outFolderPath = (
    typeof outFolder === 'string' ? outFolder : outFolder(file)
  );
  var basePath = path.resolve(cwd, outFolderPath);
  var writePath = path.resolve(basePath, file.relative);
  var writeFolder = path.dirname(writePath);

  // wire up new properties
  file.stat = (file.stat || new fs.Stats());
  file.stat.mode = options.mode;
  file.flag = options.flag;
  file.cwd = cwd;
  file.base = basePath;
  file.path = writePath;

  // mkdirp the folder the file is going in
  mkdirp(writeFolder, options.dirMode, function(err){
    if (err) {
      return cb(err);
    }
    cb(null, writePath);
  });
}

module.exports = prepareWrite;
