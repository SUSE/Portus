'use strict';

var crypto = require('crypto');

var objectAssign = require('object-assign');
var objectOmit = require('object.omit');
var Bluebird = require('bluebird');
var tryJsonParse = require('try-json-parse');

var TaskProxy = function(opts) {
  objectAssign(this, {
    task: opts.task,
    file: opts.file,
    opts: opts.opts
  });
};

function makeHash(key) {
  return crypto.createHash('md5').update(key).digest('hex');
}

objectAssign(TaskProxy.prototype, {
  processFile: function() {
    var self = this;

    return this._checkForCachedValue().then(function(cached) {
      // If we found a cached value
      if (cached.value) {
        // Extend the cached value onto the file, but don't overwrite original path info
        return objectAssign(
          self.file,
          objectOmit(cached.value, ['cwd', 'path', 'base', 'stat'])
        );
      }

      // Otherwise, run the proxied task
      return self._runProxiedTaskAndCache(cached.key);
    });
  },

  removeCachedResult: function() {
    var self = this;

    return this._getFileKey().then(function(cachedKey) {
      var removeCached = Bluebird.promisify(
        self.opts.fileCache.removeCached,
        self.opts.fileCache
      );

      return removeCached(self.opts.name, cachedKey);
    });
  },

  _getFileKey: function() {
    var getKey = this.opts.key;

    if (typeof getKey === 'function' && getKey.length === 2) {
      getKey = Bluebird.promisify(getKey, this.opts);
    }

    return Bluebird.resolve(getKey(this.file)).then(function(key) {
      if (!key) {
        return key;
      }

      return makeHash(key);
    });
  },

  _checkForCachedValue: function() {
    var self = this;

    return this._getFileKey().then(function(key) {
      // If no key returned, bug out early
      if (!key) {
        return {
          key: key,
          value: null
        };
      }

      var getCached = Bluebird.promisify(self.opts.fileCache.getCached, self.opts.fileCache);

      return getCached(self.opts.name, key).then(function(cached) {
        if (!cached) {
          return {
            key: key,
            value: null
          };
        }

        var parsedContents = tryJsonParse(cached.contents);
        if (parsedContents === undefined) {
          parsedContents = {cached: cached.contents};
        }

        if (self.opts.restore) {
          parsedContents = self.opts.restore(parsedContents);
        }

        return {
          key: key,
          value: parsedContents
        };
      });
    });
  },

  _runProxiedTaskAndCache: function(cachedKey) {
    var self = this;

    return self._runProxiedTask().then(function(result) {
      // If this wasn't a success, continue to next task
      // TODO: Should this also offer an async option?
      if (self.opts.success !== true && !self.opts.success(result)) {
        return result;
      }

      return self._storeCachedResult(cachedKey, result).then(function() {
        return result;
      });
    });
  },

  _runProxiedTask: function() {
    var self = this;
    var def = Bluebird.defer();

    function handleError(err) {
      // TODO: Errors will step on each other here

      // Reduce the maxListeners back down
      self.task.setMaxListeners(self.task._maxListeners - 1);

      def.reject(err);
    }

    function handleData(datum) {
      // Wait for data (can be out of order, so check for matching file we wrote)
      if (self.file !== datum) {
        return;
      }

      // Be good citizens and remove our listeners
      self.task.removeListener('error', handleError);
      self.task.removeListener('data', handleData);

      // Reduce the maxListeners back down
      self.task.setMaxListeners(self.task._maxListeners - 2);

      def.resolve(datum);
    }

    // Bump up max listeners to prevent memory leak warnings
    var currMaxListeners = this.task._maxListeners || 0;
    this.task.setMaxListeners(currMaxListeners + 2);

    this.task.on('data', handleData);
    this.task.once('error', handleError);

    // Run through the other task and grab output (or error)
    // Not sure if a _.defer is necessary here
    self.task.write(self.file);

    return def.promise;
  },

  _getValueFromResult: function(result) {
    var getValue;

    if (typeof this.opts.value !== 'function') {
      if (typeof this.opts.value === 'string') {
        getValue = {};
        getValue[this.opts.value] = result[this.opts.value];
      }

      return Bluebird.resolve(getValue);
    } else if (this.opts.value.length === 2) {
      // Promisify if passed a node style function
      getValue = Bluebird.promisify(this.opts.value, this.opts);
    } else {
      getValue = this.opts.value;
    }

    return Bluebird.resolve(getValue(result));
  },

  _storeCachedResult: function(key, result) {
    var self = this;

    // If we didn't have a cachedKey, skip caching result
    if (!key) {
      return Bluebird.resolve(result);
    }

    return this._getValueFromResult(result).then(function(value) {
      var val;
      var addCached = Bluebird.promisify(self.opts.fileCache.addCached, self.opts.fileCache);

      if (typeof value !== 'string') {
        if (value && typeof value === 'object' && Buffer.isBuffer(value.contents)) {
          // Shallow copy so "contents" can be safely modified
          val = objectAssign({}, value);
          val.contents = val.contents.toString('utf8');
        }

        val = JSON.stringify(value, null, 2);
      } else {
        val = value;
      }

      return addCached(self.opts.name, key, val);
    });
  }
});

module.exports = TaskProxy;
