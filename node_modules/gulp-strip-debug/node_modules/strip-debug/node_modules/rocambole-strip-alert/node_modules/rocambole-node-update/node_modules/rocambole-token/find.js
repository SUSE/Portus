"use strict";

var makeCheck = require('./makeCheck');
var isNotEmpty = require('./is').isNotEmpty;


// ---


exports.findInBetween = findInBetween;
function findInBetween(startToken, endToken, check) {
  check = makeCheck(check);
  var found;
  var last = endToken && endToken.next;
  while (startToken && startToken !== last && !found) {
    if (check(startToken)) {
      found = startToken;
    }
    startToken = startToken.next;
  }
  return found;
}


exports.findInBetweenFromEnd = findInBetweenFromEnd;
function findInBetweenFromEnd(startToken, endToken, check) {
  check = makeCheck(check);
  var found;
  var last = startToken && startToken.prev;
  while (endToken && endToken !== last && !found) {
    if (check(endToken)) {
      found = endToken;
    }
    endToken = endToken.prev;
  }
  return found;
}


exports.findNext = findNext;
function findNext(startToken, check) {
  check = makeCheck(check);
  startToken = startToken && startToken.next;
  while (startToken) {
    if (check(startToken)) {
      return startToken;
    }
    startToken = startToken.next;
  }
}


exports.findPrev = findPrev;
function findPrev(endToken, check) {
  check = makeCheck(check);
  endToken = endToken && endToken.prev;
  while (endToken) {
    if (check(endToken)) {
      return endToken;
    }
    endToken = endToken.prev;
  }
}


exports.findNextNonEmpty = findNextNonEmpty;
function findNextNonEmpty(startToken) {
  return findNext(startToken, isNotEmpty);
}


exports.findPrevNonEmpty = findPrevNonEmpty;
function findPrevNonEmpty(endToken) {
  return findPrev(endToken, isNotEmpty);
}

