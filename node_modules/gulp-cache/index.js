'use strict';

var Cache = require('cache-swap');
var File = require('vinyl');
var objectAssign = require('object-assign');
var objectOmit = require('object.omit');
var objectPick = require('object.pick');
var PluginError = require('gulp-util').PluginError;
var TaskProxy = require('./lib/TaskProxy');
var Transform = require('readable-stream/transform');

var VERSION = require('./package.json').version;
var fileCache = new Cache({cacheDirName: 'gulp-cache'});

function defaultKey(file) {
  return [VERSION, file.contents.toString('base64')].join('');
}

var defaultOptions = {
  fileCache: fileCache,
  name: 'default',
  key: defaultKey,
  restore: function(restored) {
    if (restored.contents) {
      // Handle node 0.11 buffer to JSON as object with { type: 'buffer', data: [...] }
      if (restored && restored.contents && Array.isArray(restored.contents.data)) {
        restored.contents = new Buffer(restored.contents.data);
      } else if (Array.isArray(restored.contents)) {
        restored.contents = new Buffer(restored.contents);
      } else if (typeof restored.contents === 'string') {
        restored.contents = new Buffer(restored.contents, 'base64');
      }
    }

    var restoredFile = new File(restored);
    var extraTaskProperties = objectOmit(restored, Object.keys(restoredFile));

    // Restore any properties that the original task put on the file;
    // but omit the normal properties of the file
    return objectAssign(restoredFile, extraTaskProperties);
  },
  success: true,
  value: function(file) {
    // Convert from a File object (from vinyl) into a plain object
    return objectPick(file, ['cwd', 'base', 'contents', 'stat', 'history']);
  }
};

var cacheTask = function(task, opts) {
  // Check for required task option
  if (!task) {
    throw new PluginError('gulp-cache', 'Must pass a task to cache()');
  }

  // Check if this task participates in the cacheable contract
  if (task.cacheable) {
    // Use the cacheable options, but allow the user to override them
    opts = objectAssign({}, task.cacheable, opts);
  }

  // Make sure we have some sane defaults
  opts = objectAssign({}, cacheTask.defaultOptions, opts);

  return new Transform({
    objectMode: true,
    transform: function(file, enc, cb) {
      if (file.isNull()) {
        cb(null, file);
        return;
      }

      if (file.isStream()) {
        cb(new PluginError('gulp-cache', 'Cannot operate on stream sources'));
        return;
      }

      new TaskProxy({
        task: task,
        file: file,
        opts: opts
      })
      .processFile().then(function(result) {
        cb(null, result);
      }, function(err) {
        cb(new PluginError('gulp-cache', err));
      });
    }
  });
};

cacheTask.clear = function(opts) {
  opts = objectAssign({}, cacheTask.defaultOptions, opts);

  return new Transform({
    objectMode: true,
    transform: function(file, enc, cb) {
      if (file.isNull()) {
        cb(null, file);
        return;
      }

      if (file.isStream()) {
        cb(new PluginError('gulp-cache', 'Cannot operate on stream sources'));
        return;
      }

      var taskProxy = new TaskProxy({
        task: null,
        file: file,
        opts: opts
      });

      taskProxy.removeCachedResult().then(function() {
        cb(null, file);
      }).catch(function(err) {
        cb(new PluginError('gulp-cache', err));
      });
    }
  });
};

cacheTask.clearAll = function(done) {
  fileCache.clear(null, function(err) {
    if (err) {
      var pluginError = new PluginError(
        'gulp-cache',
        'Problem clearing the cache: ' + err.message
      );

      if (done) {
        done(pluginError);
        return;
      }

      throw pluginError;
    }

    if (done) {
      done();
    }
  });
};

cacheTask.fileCache = fileCache;
cacheTask.defaultOptions = defaultOptions;
cacheTask.Cache = Cache;

module.exports = cacheTask;
