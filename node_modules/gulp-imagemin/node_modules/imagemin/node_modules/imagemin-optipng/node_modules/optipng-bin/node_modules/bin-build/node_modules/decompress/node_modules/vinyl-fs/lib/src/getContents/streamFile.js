'use strict';

var fs = require('graceful-fs');
var stripBom = require('strip-bom-stream');

function streamFile(file, opt, cb) {
  file.contents = fs.createReadStream(file.path);

  if (opt.stripBOM) {
    file.contents = file.contents.pipe(stripBom());
  }

  cb(null, file);
}

module.exports = streamFile;
