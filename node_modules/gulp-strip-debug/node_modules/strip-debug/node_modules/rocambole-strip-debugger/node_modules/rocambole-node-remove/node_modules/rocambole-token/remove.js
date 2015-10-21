"use strict";

var makeCheck = require('./makeCheck');
var isEmpty = require('./is').isEmpty;


// ---


exports.remove = remove;
function remove(target) {
  if (target.next) {
    target.next.prev = target.prev;
  } else if (target.root) {
    target.root.endToken = target.prev;
  }

  if (target.prev) {
    target.prev.next = target.next;
  } else if (target.root) {
    target.root.startToken = target.next;
  }
}


exports.removeInBetween = removeInBetween;
function removeInBetween(startToken, endToken, check) {
  check = makeCheck(check);
  var last = endToken && endToken.next;
  while (startToken && startToken !== last) {
    if (check(startToken)) {
      remove(startToken);
    }
    startToken = startToken.next;
  }
}


exports.removeAdjacent = removeAdjacent;
function removeAdjacent(token, check) {
  removeAdjacentBefore(token, check);
  removeAdjacentAfter(token, check);
}


exports.removeAdjacentBefore = removeAdjacentBefore;
function removeAdjacentBefore(token, check) {
  check = makeCheck(check);
  var prev = token.prev;
  while (prev && check(prev)) {
    remove(prev);
    prev = prev.prev;
  }
}


exports.removeAdjacentAfter = removeAdjacentAfter;
function removeAdjacentAfter(token, check) {
  check = makeCheck(check);
  var next = token.next;
  while (next && check(next)) {
    remove(next);
    next = next.next;
  }
}


exports.removeEmptyAdjacentBefore = removeEmptyAdjacentBefore;
function removeEmptyAdjacentBefore(startToken) {
  removeAdjacentBefore(startToken, isEmpty);
}


exports.removeEmptyAdjacentAfter = removeEmptyAdjacentAfter;
function removeEmptyAdjacentAfter(startToken) {
  removeAdjacentAfter(startToken, isEmpty);
}


exports.removeEmptyInBetween = removeEmptyInBetween;
function removeEmptyInBetween(startToken, endToken) {
  removeInBetween(startToken, endToken, isEmpty);
}

