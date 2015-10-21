'use strict';
var removeNode = require('rocambole-node-remove');

module.exports = function (node) {
	if (node.type === 'DebuggerStatement') {
		removeNode(node);
	}
};
