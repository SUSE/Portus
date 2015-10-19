# gulp-imagemin [![Build Status](https://travis-ci.org/sindresorhus/gulp-imagemin.svg?branch=master)](https://travis-ci.org/sindresorhus/gulp-imagemin)

> Minify PNG, JPEG, GIF and SVG images with [imagemin](https://github.com/kevva/imagemin)

*Issues with the output should be reported on the imagemin [issue tracker](https://github.com/kevva/imagemin/issues).*


## Install

```
$ npm install --save-dev gulp-imagemin
```

## Usage

```js
var gulp = require('gulp');
var imagemin = require('gulp-imagemin');
var pngquant = require('imagemin-pngquant');

gulp.task('default', function () {
	return gulp.src('src/images/*')
		.pipe(imagemin({
			progressive: true,
			svgoPlugins: [{removeViewBox: false}],
			use: [pngquant()]
		}))
		.pipe(gulp.dest('dist/images'));
});
```


## API

Comes bundled with the following **lossless** optimizers:

- [gifsicle](https://github.com/kevva/imagemin-gifsicle) — *Compress GIF images*
- [jpegtran](https://github.com/kevva/imagemin-jpegtran) — *Compress JPEG images*
- [optipng](https://github.com/kevva/imagemin-optipng) — *Compress PNG images*
- [svgo](https://github.com/kevva/imagemin-svgo) — *Compress SVG images*

### imagemin(options)

Unsupported files are ignored.

#### options

Options are applied to the correct files.

##### optimizationLevel *(png)*

Type: `number`  
Default: `3`

Select an optimization level between `0` and `7`.

> The optimization level 0 enables a set of optimization operations that require minimal effort. There will be no changes to image attributes like bit depth or color type, and no recompression of existing IDAT datastreams. The optimization level 1 enables a single IDAT compression trial. The trial chosen is what. OptiPNG thinks it’s probably the most effective. The optimization levels 2 and higher enable multiple IDAT compression trials; the higher the level, the more trials.

Level and trials:

1. 1 trial
2. 8 trials
3. 16 trials
4. 24 trials
5. 48 trials
6. 120 trials
7. 240 trials

##### progressive *(jpg)*

Type: `boolean`  
Default: `false`

Lossless conversion to progressive.

##### interlaced *(gif)*

Type: `boolean`  
Default: `false`

Interlace gif for progressive rendering.

##### multipass *(svg)*

Type: `boolean`  
Default: `false`

Optimize svg multiple times until it's fully optimized.

##### svgoPlugins *(svg)*

Type: `array`  
Default: `[]`

Customize which SVGO plugins to use. [More here](https://github.com/sindresorhus/grunt-svgmin#available-optionsplugins).

##### use

Type: `array`  
Default: `null`

Additional [plugins](https://www.npmjs.com/browse/keyword/imageminplugin) to use with imagemin.


## License

MIT © [Sindre Sorhus](http://sindresorhus.com)
