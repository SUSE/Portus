'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _assign2 = require('lodash/assign');

var _assign3 = _interopRequireDefault(_assign2);

var _map2 = require('lodash/map');

var _map3 = _interopRequireDefault(_map2);

var _each2 = require('lodash/each');

var _each3 = _interopRequireDefault(_each2);

var _startsWith2 = require('lodash/startsWith');

var _startsWith3 = _interopRequireDefault(_startsWith2);

var _orderBy2 = require('lodash/orderBy');

var _orderBy3 = _interopRequireDefault(_orderBy2);

var _toString2 = require('lodash/toString');

var _toString3 = _interopRequireDefault(_toString2);

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _fs = require('fs');

var _fs2 = _interopRequireDefault(_fs);

var _glob = require('glob');

var _glob2 = _interopRequireDefault(_glob);

var _MapCache2 = require('./MapCache');

var _MapCache3 = _interopRequireDefault(_MapCache2);

var _module = require('module');

var _module2 = _interopRequireDefault(_module);

var _util = require('./util');

var _path = require('path');

var _path2 = _interopRequireDefault(_path);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

/*----------------------------------------------------------------------------*/

var ModuleCache = function (_MapCache) {
  _inherits(ModuleCache, _MapCache);

  function ModuleCache(moduleRoot) {
    _classCallCheck(this, ModuleCache);

    var _this = _possibleConstructorReturn(this, (ModuleCache.__proto__ || Object.getPrototypeOf(ModuleCache)).call(this));

    moduleRoot = (0, _toString3.default)(moduleRoot);
    if (!moduleRoot) {
      return _possibleConstructorReturn(_this);
    }
    var pkgPath = _path2.default.join(moduleRoot, 'package.json');
    var pkgMain = _fs2.default.existsSync(pkgPath) && require(pkgPath).main || 'index.js';
    var mainPath = (0, _util.normalizePath)(_path2.default.dirname(_path2.default.resolve(moduleRoot, pkgMain)));

    // Sort paths by the “main” entry first.
    var dirPaths = (0, _orderBy3.default)(_glob2.default.sync(_path2.default.join(moduleRoot, '**/'), {
      'ignore': _path2.default.join(moduleRoot, 'node_modules/**/')
    }), function (dirPath) {
      return (0, _startsWith3.default)(dirPath, mainPath);
    }, ['desc']);

    (0, _each3.default)(dirPaths, function (dirPath) {
      var base = _path2.default.relative(moduleRoot, dirPath);
      var filePaths = _glob2.default.sync(_path2.default.join(dirPath, '*.js'));
      var pairs = (0, _map3.default)(filePaths, function (filePath) {
        var name = _path2.default.basename(filePath, '.js');
        return [name.toLowerCase(), name];
      });
      _this.set(base, new _MapCache3.default(pairs));
    });
    return _this;
  }

  _createClass(ModuleCache, null, [{
    key: 'resolve',
    value: function resolve(id) {
      var from = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : process.cwd();

      try {
        var dirs = _path2.default.dirname(_module2.default._resolveFilename(id, (0, _assign3.default)(new _module2.default(), {
          'paths': _module2.default._nodeModulePaths(from)
        }))).split(_path2.default.sep);

        var length = dirs.length;

        while (length--) {
          var dirSub = dirs.slice(0, length + 1);
          var dirPath = dirSub.join('/');
          var pkgPath = _path2.default.join(dirPath, 'package.json');

          if (length && dirs[length - 1] == 'node_modules' || _fs2.default.existsSync(pkgPath) && require(pkgPath).name == id) {
            return dirPath;
          }
        }
        return dirs.join('/');
      } catch (e) {}
      return '';
    }
  }]);

  return ModuleCache;
}(_MapCache3.default);

exports.default = ModuleCache;
;
module.exports = exports['default'];