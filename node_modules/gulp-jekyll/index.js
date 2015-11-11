'use strict';
var gutil = require('gulp-util');
var map = require('map-stream');
var spawn = require('win-spawn');
var dargs = require('dargs');

module.exports = function (options) {
	options = options || {};
	var passedArgs = dargs(options, ['bundleExec']);
	var bundleExec = options.bundleExec;

	return map(function (file, cb) {

		if (file.isStream()) {
			return cb(new gutil.PluginError('gulp-jekyll', 'Streaming not supported'));
		}

		var args = [
			'jekyll',
			'build'
		].concat(passedArgs);

		if (bundleExec) {
			args.unshift('bundle', 'exec');
		}

		var cp = spawn(args.shift(), args);

		cp.on('error', function (err) {
			return cb(new gutil.PluginError('gulp-jekyll', err));
		});

		var errors = '';
		cp.stderr.setEncoding('utf8');
		cp.stderr.on('data', function (data) {
			errors += data;
		});

		cp.on('close', function (code) {
			if (code === 127) {
				return cb(new gutil.PluginError('gulp-jekyll', 'You need to have Ruby and Jekyll installed and in your PATH for this task to work.'));
			}

			if (errors) {
				return cb(new gutil.PluginError('gulp-jekyll', '\n' + errors.replace('Use --trace for backtrace.\n', '')));
			}

			if (code > 0) {
				return cb(new gutil.PluginError('gulp-jekyll', 'Exited with error code ' + code));
			}

			cb(null, null);

		});
	});
};