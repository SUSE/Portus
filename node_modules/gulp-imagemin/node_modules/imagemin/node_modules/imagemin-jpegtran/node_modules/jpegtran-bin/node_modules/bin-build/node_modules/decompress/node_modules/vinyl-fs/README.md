# vinyl-fs [![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url] [![Coveralls Status][coveralls-image]][coveralls-url] [![Dependency Status][depstat-image]][depstat-url]
## Information
<table>
  <tr><td>Package</td><td>vinyl-fs</td></tr>
  <tr><td>Description</td><td>Vinyl adapter for the file system</td></tr>
  <tr><td>Node Version</td><td>>= 0.10</td></tr>
</table>

## Usage

```javascript
var map = require('map-stream');
var fs = require('vinyl-fs');

var log = function(file, cb) {
  console.log(file.path);
  cb(null, file);
};

fs.src(['./js/**/*.js', '!./js/vendor/*.js'])
  .pipe(map(log))
  .pipe(fs.dest('./output'));
```

## API
### src(globs[, opt])
- Takes a glob string or an array of glob strings as the first argument.
- Globs are executed in order, so negations should follow positive globs. For example:

```js
fs.src(['!b*.js', '*.js'])
```

would not exclude any files, but this would

```js
fs.src(['*.js', '!b*.js'])
```

- Possible options for the second argument:
  - cwd - Specify the working directory the folder is relative to.
    - Default is `process.cwd()`.

  - base - Specify the folder relative to the cwd. This is used to determine the file names when saving in `.dest()`.
    - Default is where the glob begins if any.
    - Default is `process.cwd()` if there is no glob.

  - buffer - `true` or `false` if you want to buffer the file.
    - Default value is `true`.
    - `false` will make `file.contents` a paused Stream.

  - read - `true` or `false` if you want the file to be read or not. Useful for stuff like `rm`ing files.
    - Default value is `true`.
    - `false` will disable writing the file to disk via `.dest()`.

  - since - `Date` or `number` if you only want files that have been modified since the time specified.
  - stripBOM - `true` or `false` if you want the BOM to be stripped on UTF-8 encoded files.
    - Default value is `true`.

  - passthrough - `true` or `false` if you want a duplex stream which passes items through and emits globbed files.
    - Default is `false`.

  - sourcemaps - `true` or `false` if you want files to have sourcemaps enabled.
    - Default is `false`.
    - Will load inline sourcemaps and resolve sourcemap links from files
    - Uses `gulp-sourcemaps` under the hood

  - followSymlinks - `true` if you want to recursively resolve symlinks to their targets; set to `false` to preserve them as symlinks.
    - Default is `true`.
    - `false` will make `file.symlink` equal the original symlink's target path.

  - Any glob-related options are documented in [glob-stream] and [node-glob].

- Returns a Readable stream by default, or a Duplex stream if the `passthrough` option is set to `true`.
- This stream emits matching [vinyl] File objects.

_Note:_ UTF-8 BOM will be stripped from all UTF-8 files read with `.src`.

### dest(folder[, opt])
- Takes a folder path as the first argument.
- First argument can also be a function that takes in a file and returns a folder path.
- Possible options for the second argument:
  - cwd - Specify the working directory the folder is relative to.
    - Default is `process.cwd()`.

  - base - Specify the folder relative to the cwd. This is used to determine the file names when saving in `.dest()`.
    - Default is the `cwd` resolves to the folder path.
    - Can also be a function that takes in a file and returns a folder path.

  - mode - Specify the mode the files should be created with.
    - Default is the mode of the input file (file.stat.mode) if any.
    - Default is the process mode if the input file has no mode property.

  - dirMode - Specify the mode the directory should be created with.
    - Default is the process mode.

  - overwrite - Specify if existing files with the same path should be overwritten or not.
    - Default is `true`, to always overwrite existing files.
    - Can also be a function that takes in a file and returns `true` or `false`.

  - sourcemaps -
    - Default is `null` aka do not write sourcemaps.
    - Uses `gulp-sourcemaps` under the hood
    - Examples:
      - Write as inline comments
      - fs.dest('./', {sourcemaps: true})
      - Write as files in the same folder
      - fs.dest('./', {<br>  sourcemaps: {<br>    path: '.'<br>  }<br>})
      - Any other options are passed through to `gulp-sourcemaps`
      - fs.dest('./', {<br>  sourcemaps: {<br>    path: '.',<br>    addComment: false,<br>    includeContent: false<br>  }<br>})

- Returns a Readable/Writable stream.
- On write the stream will save the [vinyl] File to disk at the folder/cwd specified.
- After writing the file to disk, it will be emitted from the stream so you can keep piping these around.
- If the file has a `symlink` attribute specifying a target path, then a symlink will be created.
- The file will be modified after being written to this stream:
  - `cwd`, `base`, and `path` will be overwritten to match the folder.
  - `stat.mode` will be overwritten if you used a mode parameter.
  - `contents` will have it's position reset to the beginning if it is a stream.

### symlink(folder[, opt])
- Takes a folder path as the first argument.
- First argument can also be a function that takes in a file and returns a folder path.
- Possible options for the second argument:
  - cwd - Specify the working directory the folder is relative to.
    - Default is `process.cwd()`.

  - base - Specify the folder relative to the cwd. This is used to determine the file names when saving in `.dest()`.
    - Default is the `cwd` resolves to the folder path.
    - Can also be a function that takes in a file and returns a folder path.

  - dirMode - Specify the mode the directory should be created with.
    - Default is the process mode.

- Returns a Readable/Writable stream.
- On write the stream will create a symbolic link (i.e. symlink) on disk at the folder/cwd specified.
- After creating the symbolic link, it will be emitted from the stream so you can keep piping these around.
- The file will be modified after being written to this stream:
  - `cwd`, `base`, and `path` will be overwritten to match the folder.

[glob-stream]: https://github.com/gulpjs/glob-stream
[node-glob]: https://github.com/isaacs/node-glob
[gaze]: https://github.com/shama/gaze
[glob-watcher]: https://github.com/gulpjs/glob-watcher
[vinyl]: https://github.com/gulpjs/vinyl
[npm-url]: https://www.npmjs.com/package/vinyl-fs
[npm-image]: https://badge.fury.io/js/vinyl-fs.svg
[travis-url]: https://travis-ci.org/gulpjs/vinyl-fs
[travis-image]: https://travis-ci.org/gulpjs/vinyl-fs.svg?branch=master
[coveralls-url]: https://coveralls.io/r/wearefractal/vinyl-fs
[coveralls-image]: https://img.shields.io/coveralls/wearefractal/vinyl-fs.svg?style=flat
[depstat-url]: https://david-dm.org/gulpjs/vinyl-fs
[depstat-image]: https://david-dm.org/gulpjs/vinyl-fs.svg
