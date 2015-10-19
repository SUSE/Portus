'use strict';

var isSvg = require('is-svg');
var SVGO = require('svgo');
var through = require('through2');

module.exports = function (opts) {
	opts = opts || {};

	return through.ctor({objectMode: true}, function (file, enc, cb) {
		if (file.isNull()) {
			cb(null, file);
			return;
		}

		if (file.isStream()) {
			cb(new Error('Streaming is not supported'));
			return;
		}

		if (!isSvg(file.contents)) {
			cb(null, file);
			return;
		}

		try {
			var svgo = new SVGO({
				multipass: opts.multipass || false,
				plugins: opts.plugins || []
			});

			svgo.optimize(file.contents.toString('utf8'), function (res) {
				if (!res.data) {
					cb(null, file);
					return;
				}

				if (res.data && res.data.length) {
					res.data = res.data.replace(/&(?!amp;)/g, '&amp;');
				}

				res.data = new Buffer(res.data);

				if (res.data.length < file.contents.length) {
					file.contents = res.data;
				}

				cb(null, file);
			});
		} catch (err) {
			cb(err);
		}
	});
};
