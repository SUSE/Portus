'use strict';
var token = require('rocambole-token');

module.exports = function (node) {
	token.eachInBetween(node.startToken, node.endToken, token.remove);
};
