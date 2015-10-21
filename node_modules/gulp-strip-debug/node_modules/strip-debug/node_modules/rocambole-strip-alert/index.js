'use strict';
var updateNode = require('rocambole-node-update');

module.exports = function (node) {
	if (node.type !== 'CallExpression') {
		return;
	}
	var main = node.callee;

	// collapse `window`
	if (main && main.type === 'MemberExpression' && main.object && main.object.type === 'Identifier' && main.object.name === 'window' && main.property) {
		main = main.property;
	}

	if (main.type === 'Identifier' && main.name === 'alert') {
		updateNode(node, 'void 0');
	}
};
