/*!
 * object.pick <https://github.com/jonschlinkert/object.pick>
 *
 * Copyright (c) 2014-2015 Jon Schlinkert, contributors.
 * Licensed under the MIT License
 */

'use strict';

module.exports = function pick(obj, keys) {
  var res = {};
  var i = 0;

  if (typeof obj !== 'object') {
    return res;
  }

  if (typeof keys === 'string') {
    if (keys in obj) {
      res[keys] = obj[keys];
    }
    return res;
  }

  var len = keys.length;

  while (len--) {
    var key = keys[i++];
    if (key in obj) {
      res[key] = obj[key];
    }
  }
  return res;
};
