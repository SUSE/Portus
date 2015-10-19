"use strict";

function tryToParseJson(string, reviver) {
  var result;

  try {
    result = JSON.parse(string, reviver);
  } catch (error) {
    // oh error? well just return undefined, no biggie
  }

  return result;
}

module.exports = tryToParseJson;
