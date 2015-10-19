# duplexer2 [![Build Status](https://travis-ci.org/deoxxa/duplexer2.svg?branch=master)](https://travis-ci.org/deoxxa/duplexer2) [![Coverage Status](https://coveralls.io/repos/deoxxa/duplexer2/badge.svg?branch=master&service=github)](https://coveralls.io/github/deoxxa/duplexer2?branch=master)

Like [duplexer](https://github.com/Raynos/duplexer) but using Streams3

```javascript
const duplexer2 = require(".");
const {Readable, Writable} = require("stream");

const writable = new Writable({
  write(data, enc, cb) {
    if (readable.push(data)) {
      cb();
      return;
    }
    readable.once("drain", cb);
  }
});

const readable = new Readable({read() {/* no-op */}});

// simulate the readable thing closing after a bit
writable.once("finish", () => setTimeout(() => readable.push(null), 300));

const duplex = duplexer2({}, writable, readable)
.on("data", data => console.log("got data", data.toString()))
.on("finish", () => console.log("got finish event"))
.on("end", () => console.log("got end event"));

duplex.write("oh, hi there", () => console.log("finished writing"));
duplex.end(() => console.log("finished ending"));
```

```
got data "oh, hi there"
finished writing
got finish event
finished ending
got end event
```

## Overview

This is a reimplementation of [duplexer](https://www.npmjs.com/package/duplexer) using the
Streams3 API which is standard in Node as of v4. Everything largely
works the same.



## Installation

[Available via `npm`](https://docs.npmjs.com/cli/install):

```
$ npm i duplexer2
```

## API

### duplexer2

Creates a new `DuplexWrapper` object, which is the actual class that implements
most of the fun stuff. All that fun stuff is hidden. DON'T LOOK.

```javascript
duplexer2([options], writable, readable)
```

```javascript
const duplex = duplexer2(new stream.Writable(), new stream.Readable());
```

Arguments

* __options__ - an object specifying the regular `stream.Duplex` options, as
  well as the properties described below.
* __writable__ - a writable stream
* __readable__ - a readable stream

Options

* __bubbleErrors__ - a boolean value that specifies whether to bubble errors
  from the underlying readable/writable streams. Default is `true`.


## License

3-clause BSD. [A copy](./LICENSE) is included with the source.

## Contact

* GitHub ([deoxxa](http://github.com/deoxxa))
* Twitter ([@deoxxa](http://twitter.com/deoxxa))
* Email ([deoxxa@fknsrs.biz](mailto:deoxxa@fknsrs.biz))
