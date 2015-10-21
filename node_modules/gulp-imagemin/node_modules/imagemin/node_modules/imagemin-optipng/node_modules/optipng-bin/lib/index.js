'use strict';

var BinWrapper = require('bin-wrapper');
var path = require('path');
var pkg = require('../package.json');
var url = 'https://raw.github.com/imagemin/optipng-bin/' + pkg.version + '/vendor/';

module.exports = new BinWrapper()
	.src(url + 'osx/optipng', 'darwin')
	.src(url + 'linux/x86/optipng', 'linux', 'x86')
	.src(url + 'linux/x64/optipng', 'linux', 'x64')
	.src(url + 'freebsd/optipng', 'freebsd')
	.src(url + 'sunos/x86/optipng', 'sunos', 'x86')
	.src(url + 'sunos/x64/optipng', 'sunos', 'x64')
	.src(url + 'win/optipng.exe', 'win32')
	.dest(path.join(__dirname, '../vendor'))
	.use(process.platform === 'win32' ? 'optipng.exe' : 'optipng')
	.version('>=0.7.5');
