"use strict";

exports.before = before;
function before(target, newToken) {
  newToken.prev = target.prev;
  newToken.next = target;
  if (target.prev) {
    target.prev.next = newToken;
  } else if (target.root) {
    target.root.startToken = newToken;
  }
  target.prev = newToken;
  newToken.root = target.root;
  return newToken;
}


exports.after = after;
function after(target, newToken) {
  if (target.next) {
    target.next.prev = newToken;
  } else if (target.root) {
    target.root.endToken = newToken;
  }
  newToken.prev = target;
  newToken.next = target.next;
  target.next = newToken;
  newToken.root = target.root;
  return newToken;
}

