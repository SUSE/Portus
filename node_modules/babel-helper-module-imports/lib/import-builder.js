"use strict";

exports.__esModule = true;
exports.default = void 0;

var _assert = _interopRequireDefault(require("assert"));

var t = _interopRequireWildcard(require("babel-types"));

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var ImportBuilder = function () {
  function ImportBuilder(importedSource, scope, file) {
    Object.defineProperty(this, "_statements", {
      configurable: true,
      enumerable: true,
      writable: true,
      value: []
    });
    Object.defineProperty(this, "_resultName", {
      configurable: true,
      enumerable: true,
      writable: true,
      value: null
    });
    Object.defineProperty(this, "_scope", {
      configurable: true,
      enumerable: true,
      writable: true,
      value: null
    });
    Object.defineProperty(this, "_file", {
      configurable: true,
      enumerable: true,
      writable: true,
      value: null
    });
    this._scope = scope;
    this._file = file;
    this._importedSource = importedSource;
  }

  var _proto = ImportBuilder.prototype;

  _proto.done = function done() {
    return {
      statements: this._statements,
      resultName: this._resultName
    };
  };

  _proto.import = function _import() {
    this._statements.push(t.importDeclaration([], t.stringLiteral(this._importedSource)));

    return this;
  };

  _proto.require = function require() {
    this._statements.push(t.expressionStatement(t.callExpression(t.identifier("require"), [t.stringLiteral(this._importedSource)])));

    return this;
  };

  _proto.namespace = function namespace(name) {
    name = this._scope.generateUidIdentifier(name);
    var statement = this._statements[this._statements.length - 1];
    (0, _assert.default)(statement.type === "ImportDeclaration");
    (0, _assert.default)(statement.specifiers.length === 0);
    statement.specifiers = [t.importNamespaceSpecifier(name)];
    this._resultName = t.clone(name);
    return this;
  };

  _proto.default = function _default(name) {
    name = this._scope.generateUidIdentifier(name);
    var statement = this._statements[this._statements.length - 1];
    (0, _assert.default)(statement.type === "ImportDeclaration");
    (0, _assert.default)(statement.specifiers.length === 0);
    statement.specifiers = [t.importDefaultSpecifier(name)];
    this._resultName = t.clone(name);
    return this;
  };

  _proto.named = function named(name, importName) {
    if (importName === "default") return this.default(name);
    name = this._scope.generateUidIdentifier(name);
    var statement = this._statements[this._statements.length - 1];
    (0, _assert.default)(statement.type === "ImportDeclaration");
    (0, _assert.default)(statement.specifiers.length === 0);
    statement.specifiers = [t.importSpecifier(name, t.identifier(importName))];
    this._resultName = t.clone(name);
    return this;
  };

  _proto.var = function _var(name) {
    name = this._scope.generateUidIdentifier(name);
    var statement = this._statements[this._statements.length - 1];

    if (statement.type !== "ExpressionStatement") {
      (0, _assert.default)(this._resultName);
      statement = t.expressionStatement(this._resultName);

      this._statements.push(statement);
    }

    this._statements[this._statements.length - 1] = t.variableDeclaration("var", [t.variableDeclarator(name, statement.expression)]);
    this._resultName = t.clone(name);
    return this;
  };

  _proto.defaultInterop = function defaultInterop() {
    return this._interop(this._file.addHelper("interopRequireDefault"));
  };

  _proto.wildcardInterop = function wildcardInterop() {
    return this._interop(this._file.addHelper("interopRequireWildcard"));
  };

  _proto._interop = function _interop(callee) {
    var statement = this._statements[this._statements.length - 1];

    if (statement.type === "ExpressionStatement") {
      statement.expression = t.callExpression(callee, [statement.expression]);
    } else if (statement.type === "VariableDeclaration") {
      (0, _assert.default)(statement.declarations.length === 1);
      statement.declarations[0].init = t.callExpression(callee, [statement.declarations[0].init]);
    } else {
      _assert.default.fail("Unexpected type.");
    }

    return this;
  };

  _proto.prop = function prop(name) {
    var statement = this._statements[this._statements.length - 1];

    if (statement.type === "ExpressionStatement") {
      statement.expression = t.memberExpression(statement.expression, t.identifier(name));
    } else if (statement.type === "VariableDeclaration") {
      (0, _assert.default)(statement.declarations.length === 1);
      statement.declarations[0].init = t.memberExpression(statement.declarations[0].init, t.identifier(name));
    } else {
      _assert.default.fail("Unexpected type:" + statement.type);
    }

    return this;
  };

  _proto.read = function read(name) {
    this._resultName = t.memberExpression(this._resultName, t.identifier(name));
  };

  return ImportBuilder;
}();

exports.default = ImportBuilder;