'use strict';
var path = require('path');
var gutil = require('gulp-util');
var through = require('through2-concurrent');
var assign = require('object-assign');
var prettyBytes = require('pretty-bytes');
var chalk = require('chalk');
var Imagemin = require('imagemin');
var plur = require('plur');

module.exports = function (opts) {
	opts = assign({
		// TODO: remove this when gulp get's a real logger with levels
		verbose: process.argv.indexOf('--verbose') !== -1
	}, opts);

	var totalBytes = 0;
	var totalSavedBytes = 0;
	var totalFiles = 0;
	var validExts = ['.jpg', '.jpeg', '.png', '.gif', '.svg'];

	return through.obj(function (file, enc, cb) {
		if (file.isNull()) {
			cb(null, file);
			return;
		}

		if (file.isStream()) {
			cb(new gutil.PluginError('gulp-imagemin', 'Streaming not supported'));
			return;
		}

		if (validExts.indexOf(path.extname(file.path).toLowerCase()) === -1) {
			if (opts.verbose) {
				gutil.log('gulp-imagemin: Skipping unsupported image ' + chalk.blue(file.relative));
			}

			cb(null, file);
			return;
		}

		var imagemin = new Imagemin()
			.src(file.contents)
			.use(Imagemin.gifsicle({interlaced: opts.interlaced}))
			.use(Imagemin.jpegtran({progressive: opts.progressive}))
			.use(Imagemin.optipng({optimizationLevel: opts.optimizationLevel}))
			.use(Imagemin.svgo({
				plugins: opts.svgoPlugins || [],
				multipass: opts.multipass
			}));

		if (opts.use) {
			opts.use.forEach(imagemin.use.bind(imagemin));
		}

		imagemin.run(function (err, files) {
			if (err) {
				cb(new gutil.PluginError('gulp-imagemin:', err, {fileName: file.path}));
				return;
			}

			var originalSize = file.contents.length;
			var optimizedSize = files[0].contents.length;
			var saved = originalSize - optimizedSize;
			var percent = originalSize > 0 ? (saved / originalSize) * 100 : 0;
			var savedMsg = 'saved ' + prettyBytes(saved) + ' - ' + percent.toFixed(1).replace(/\.0$/, '') + '%';
			var msg = saved > 0 ? savedMsg : 'already optimized';

			totalBytes += originalSize;
			totalSavedBytes += saved;
			totalFiles++;

			if (opts.verbose) {
				gutil.log('gulp-imagemin:', chalk.green('✔ ') + file.relative + chalk.gray(' (' + msg + ')'));
			}

			file.contents = files[0].contents;
			cb(null, file);
		});
	}, function (cb) {
		var percent = totalBytes > 0 ? (totalSavedBytes / totalBytes) * 100 : 0;
		var msg = 'Minified ' + totalFiles + ' ' + plur('image', totalFiles);

		if (totalFiles > 0) {
			msg += chalk.gray(' (saved ' + prettyBytes(totalSavedBytes) + ' - ' + percent.toFixed(1).replace(/\.0$/, '') + '%)');
		}

		gutil.log('gulp-imagemin:', msg);
		cb();
	});
};
