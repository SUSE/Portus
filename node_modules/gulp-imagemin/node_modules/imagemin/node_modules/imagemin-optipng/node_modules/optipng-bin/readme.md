# optipng-bin [![Build Status](http://img.shields.io/travis/imagemin/optipng-bin.svg?style=flat)](http://travis-ci.org/imagemin/optipng-bin)

> [OptiPNG](http://optipng.sourceforge.net) is a PNG optimizer that recompresses 
image files to a smaller size, without losing any information.


## Install

```
$ npm install --save optipng-bin
```


## Usage

```js
var execFile = require('child_process').execFile;
var optipng = require('optipng-bin');

execFile(optipng, ['-out', 'output.png', 'input.png'], function (err) {
	console.log('Image minified!');
});
```


## CLI

```
$ npm install --global optipng-bin
```

```
$ optipng --help
```


## License

MIT © [imagemin](https://github.com/imagemin)
