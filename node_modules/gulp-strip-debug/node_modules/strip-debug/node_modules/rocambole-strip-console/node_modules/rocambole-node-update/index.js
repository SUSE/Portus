'use strict';
var rocamboleToken = require('rocambole-token');

module.exports = function (node, str) {
	var newToken = {
		type: 'custom',
		value: str
	};

	if (node.startToken) {
		rocamboleToken.before(node.startToken, newToken);
	}

	if (node.endToken) {
		rocamboleToken.after(node.endToken, newToken);
	}
};
