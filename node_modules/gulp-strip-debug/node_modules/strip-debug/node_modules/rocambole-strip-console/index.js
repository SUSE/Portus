'use strict';
var updateNode = require('rocambole-node-update');

module.exports = function (node) {
	if (node.type !== 'CallExpression') {
		return;
	}

	var expression = node.callee;

	if (expression && expression.type !== 'MemberExpression') {
		return;
	}

	var main = expression.object;

	// collapse `window`
	if (main && main.type === 'MemberExpression' && main.object && main.object.type === 'Identifier' && main.object.name === 'window' && main.property) {
		main = main.property;
	}

	if (main && main.type === 'Identifier' && main.name === 'console' && expression.property) {
		updateNode(node, 'void 0');
	}
};
