/*!
 * sum-up | MIT (c) Shinnosuke Watanabe
 * https://github.com/shinnn/sum-up
*/
'use strict';

var Chalk = require('chalk').constructor;

module.exports = function sumUp(data) {
  if (typeof data !== 'object') {
    throw new TypeError('Argument must be an object.');
  }

  var chalk = new Chalk({enabled: data.color});
  var lines = [];

  var nameAndVersion = chalk.cyan(data.name || '');
  if (data.version) {
    if (data.name) {
      nameAndVersion += ' ';
    }
    nameAndVersion += chalk.gray('v' + data.version);
  }

  if (nameAndVersion) {
    lines.push(nameAndVersion);
  }

  if (data.homepage) {
    lines.push(chalk.gray(data.homepage));
  }

  if (data.description) {
    lines.push(data.description);
  }

  return lines.join('\n');
};
