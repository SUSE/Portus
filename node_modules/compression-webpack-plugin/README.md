# compression plugin for webpack

## Usage

``` javascript
var CompressionPlugin = require("compression-webpack-plugin");
module.exports = {
	plugins: [
		new CompressionPlugin({
			asset: "[path].gz[query]",
			algorithm: "gzip",
			test: /\.js$|\.html$/,
			threshold: 10240,
			minRatio: 0.8
		})
	]
}
```

Arguments:

* `asset`: The target asset name. `[file]` is replaced with the original asset. `[path]` is replaced with the path of the original asset and `[query]` with the query. Defaults to `"[path].gz[query]"`.
* `algorithm`: Can be a `function(buf, callback)` or a string. For a string the algorithm is taken from `zlib` (or zopfli for `zopfli`). Defaults to `"gzip"`.
* `test`: All assets matching this RegExp are processed. Defaults to every asset.
* `threshold`: Only assets bigger than this size are processed. In bytes. Defaults to `0`.
* `minRatio`: Only assets that compress better that this ratio are processed. Defaults to `0.8`.

Option Arguments for Zopfli (see [node-zopfli](https://github.com/pierreinglebert/node-zopfli#options) doc for details):
* verbose: Default: false,
* verbose_more: Default: false,
* numiterations: Default: 15,
* blocksplitting: Default: true,
* blocksplittinglast: Default: false,
* blocksplittingmax: Default: 15

## License

MIT (http://www.opensource.org/licenses/mit-license.php)