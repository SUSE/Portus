"use strict";

exports.__esModule = true;
exports.default = isModule;

function isModule(path, requireUnambiguous) {
  if (requireUnambiguous === void 0) {
    requireUnambiguous = false;
  }

  var sourceType = path.node.sourceType;

  if (sourceType !== "module" && sourceType !== "script") {
    throw path.buildCodeFrameError("Unknown sourceType \"" + sourceType + "\", cannot transform.");
  }

  var filename = path.hub.file.opts.filename;

  if (/\.mjs$/.test(filename)) {
    requireUnambiguous = false;
  }

  return path.node.sourceType === "module" && (!requireUnambiguous || isUnambiguousModule(path));
}

function isUnambiguousModule(path) {
  return path.get("body").some(function (p) {
    return p.isModuleDeclaration();
  });
}