'use strict';

var path = require('path');

var assign = require('object-assign');
var fs = require('graceful-fs');
var mkdirp = require('mkdirp');
var rimraf = require('rimraf');
var tmpDir = require('os').tmpDir();

function CacheSwap(options) {
  this.options = assign({
    tmpDir: tmpDir,
    cacheDirName: 'defaultCacheSwap'
  }, options);
}

assign(CacheSwap.prototype, {
  clear: function(category, cb) {
    var dir = path.join(this.options.tmpDir, this.options.cacheDirName, category || '');
    rimraf(dir, {disableGlob: true}, cb);
  },

  hasCached: function(category, hash, cb) {
    var filePath = this.getCachedFilePath(category, hash);

    fs.exists(filePath, function(exists) {
      return cb(exists, exists ? filePath : null);
    });
  },

  getCached: function(category, hash, cb) {
    var filePath = this.getCachedFilePath(category, hash);

    fs.readFile(filePath, function(err, fileStream) {
      if (err) {
        if (err.code === 'ENOENT') {
          cb();
          return;
        }

        cb(err);
        return;
      }

      cb(null, {
        contents: fileStream.toString(),
        path: filePath
      });
    });
  },

  addCached: function(category, hash, contents, cb) {
    var filePath = this.getCachedFilePath(category, hash);

    mkdirp(path.dirname(filePath), {mode: parseInt('0777', 8)}, function(mkdirErr) {
      if (mkdirErr) {
        cb(mkdirErr);
        return;
      }

      fs.writeFile(filePath, contents, {mode: parseInt('0777', 8)}, function(writeErr) {
        if (writeErr) {
          cb(writeErr);
          return;
        }

        fs.chmod(filePath, parseInt('0777', 8), function(chmodErr) {
          if (chmodErr) {
            cb(chmodErr);
            return;
          }

          cb(null, filePath);
        });
      });
    });
  },

  removeCached: function(category, hash, cb) {
    var filePath = this.getCachedFilePath(category, hash);

    fs.unlink(filePath, function(err) {
      if (err) {
        if (err.code === 'ENOENT') {
          cb();
          return;
        }

        cb(err);
        return;
      }

      cb();
    });
  },

  getCachedFilePath: function(category, hash) {
    return path.join(this.options.tmpDir, this.options.cacheDirName, category, hash);
  }
});

module.exports = CacheSwap;
