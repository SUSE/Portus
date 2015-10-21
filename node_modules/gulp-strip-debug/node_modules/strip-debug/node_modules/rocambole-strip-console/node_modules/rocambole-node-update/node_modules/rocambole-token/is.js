"use strict";


// ---


exports.isWs = isWs;
function isWs(token) {
  return token && token.type === 'WhiteSpace';
}


exports.isBr = isBr;
function isBr(token) {
  return token && token.type === 'LineBreak';
}


exports.isEmpty = isEmpty;
function isEmpty(token) {
  return token &&
    (token.type === 'WhiteSpace' ||
    token.type === 'LineBreak' ||
    token.type === 'Indent');
}


exports.isNotEmpty = isNotEmpty;
function isNotEmpty(token) {
  return !isEmpty(token);
}


//XXX: isCode is a bad name, find something better to describe it
exports.isCode = isCode;
function isCode(token) {
  return !isEmpty(token) && !isComment(token);
}


exports.isSemiColon = isSemiColon;
function isSemiColon(token) {
  return token && (token.type === 'Punctuator' && token.value === ';');
}


exports.isComma = isComma;
function isComma(token) {
  return token && (token.type === 'Punctuator' && token.value === ',');
}


exports.isIndent = isIndent;
function isIndent(token) {
  return token && token.type === 'Indent';
}


exports.isComment = isComment;
function isComment(token) {
  return token && (token.type === 'LineComment' || token.type === 'BlockComment');
}

