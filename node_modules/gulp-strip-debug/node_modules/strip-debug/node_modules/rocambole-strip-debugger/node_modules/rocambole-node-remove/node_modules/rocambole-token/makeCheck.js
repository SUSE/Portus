"use strict";

module.exports = makeCheck;

function makeCheck(orig) {
  if (typeof orig === 'string') {
    return makeStringCheck(orig);
  }
  else if (Array.isArray(orig)) {
    return makeArrayCheck(orig);
  }
  // already a function or invalid value
  return orig;
}


function makeArrayCheck(arr) {
  return function checkTypeAndValueByIndex(token) {
    return token && (arr.indexOf(token.type) !== -1 || arr.indexOf(token.value) !== -1);
  };
}


function makeStringCheck(str) {
  return function checkTypeAndValueByString(token) {
    return token && (token.type === str || token.value === str);
  };
}
