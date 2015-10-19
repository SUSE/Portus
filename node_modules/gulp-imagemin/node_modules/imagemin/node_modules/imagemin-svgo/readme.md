# imagemin-svgo [![Build Status](http://img.shields.io/travis/imagemin/imagemin-svgo.svg?style=flat)](https://travis-ci.org/imagemin/imagemin-svgo) [![Build status](https://ci.appveyor.com/api/projects/status/esa7m3u8bcol1mtr?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/imagemin-svgo)

> svgo imagemin plugin


## Install

```sh
$ npm install --save imagemin-svgo
```


## Usage

```js
var Imagemin = require('imagemin');
var svgo = require('imagemin-svgo');

var imagemin = new Imagemin()
	.src('images/*.svg')
	.dest('build/images')
	.use(svgo());

imagemin.run(function (err, files) {
	if (err) {
		throw err;
	}

	console.log('Files optimized successfully!'); 
});
```

You can also use this plugin with [gulp](http://gulpjs.com):

```js
var gulp = require('gulp');
var svgo = require('imagemin-svgo');

gulp.task('default', function () {
	return gulp.src('images/*.svg')
		.pipe(svgo()())
		.pipe(gulp.dest('build/images'));
});
```


## Options

### multipass

Type: `Boolean`  
Default: `false`

Optimize image multiple times until it's fully optimized.

### plugins

Type: `Array`  
Default: `[]`

Customize which SVGO [plugins](https://github.com/svg/svgo/tree/master/plugins) to use.

```js
var imagemin = new Imagemin()
	.use(svgo({plugins: [{removeViewBox: false}, {removeEmptyAttrs: false}]}));
```


## License

MIT © [imagemin](https://github.com/imagemin)
