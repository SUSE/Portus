# yauzl

[![Build Status](https://travis-ci.org/thejoshwolfe/yauzl.svg?branch=master)](https://travis-ci.org/thejoshwolfe/yauzl)
[![Coverage Status](https://img.shields.io/coveralls/thejoshwolfe/yauzl.svg)](https://coveralls.io/r/thejoshwolfe/yauzl)

yet another unzip library for node. For zipping, see
[yazl](https://github.com/thejoshwolfe/yazl).

Design principles:

 * Follow the spec.
   Don't scan for local file headers.
   Read the central directory for file metadata.
   (see [No Streaming Unzip API](#no-streaming-unzip-api)).
 * Don't block the JavaScript thread.
   Use and provide async APIs.
 * Keep memory usage under control.
   Don't attempt to buffer entire files in RAM at once.
 * Never crash (if used properly).
   Don't let malformed zip files bring down client applications who are trying to catch errors.
 * Catch unsafe filenames entries.
   A zip file entry throws an error if its file name starts with `"/"` or `/[A-Za-z]:\//`
   or if it contains `".."` path segments or `"\\"` (per the spec).

## Usage

```js
var yauzl = require("yauzl");
var fs = require("fs");

yauzl.open("path/to/file.zip", function(err, zipfile) {
  if (err) throw err;
  zipfile.on("entry", function(entry) {
    if (/\/$/.test(entry.fileName)) {
      // directory file names end with '/'
      return;
    }
    zipfile.openReadStream(entry, function(err, readStream) {
      if (err) throw err;
      // ensure parent directory exists, and then:
      readStream.pipe(fs.createWriteStream(entry.fileName));
    });
  });
});
```

## API

The default for every `callback` parameter is:

```js
function defaultCallback(err) {
  if (err) throw err;
}
```

### open(path, [options], [callback])

Calls `fs.open(path, "r")` and gives the `fd`, `options`, and `callback` to `fromFd()` below.

`options` may be omitted or `null` and defaults to `{autoClose: true}`.

### fromFd(fd, [options], [callback])

Reads from the fd, which is presumed to be an open .zip file.
Note that random access is required by the zip file specification,
so the fd cannot be an open socket or any other fd that does not support random access.

The `callback` is given the arguments `(err, zipfile)`.
An `err` is provided if the End of Central Directory Record Signature cannot be found in the file,
which indicates that the fd is not a zip file.
`zipfile` is an instance of `ZipFile`.

`options` may be omitted or `null` and defaults to `{autoClose: false}`.
`autoClose` is effectively equivalent to:

```js
zipfile.once("end", function() {
  zipfile.close();
});
```

### fromBuffer(buffer, [callback])

Like `fromFd()`, but reads from a RAM buffer instead of an open file.
`buffer` is a `Buffer`.
`callback` is effectively passed directly to `fromFd()`.

If a `ZipFile` is acquired from this method,
it will never emit the `close` event,
and calling `close()` is not necessary.

### dosDateTimeToDate(date, time)

Converts MS-DOS `date` and `time` data into a JavaScript `Date` object.
Each parameter is a `Number` treated as an unsigned 16-bit integer.
Note that this format does not support timezones,
so the returned object will use the local timezone.

### Class: ZipFile

The constructor for the class is not part of the public API.
Use `open()`, `fromFd()`, or `fromBuffer()` instead.

#### Event: "entry"

Callback gets `(entry)`, which is an `Entry`.

#### Event: "end"

Emitted after the last `entry` event has been emitted.

#### Event: "close"

Emitted after the fd is actually closed.
This is after calling `close()` (or after the `end` event when `autoClose` is `true`),
and after all streams created from `openReadStream()` have emitted their `end` events.

This event is never emitted if this `ZipFile` was acquired from `fromBuffer()`.

#### Event: "error"

Emitted in the case of errors with reading the zip file.
(Note that other errors can be emitted from the streams created from `openReadStream()` as well.)
After this event has been emitted, no further `entry`, `end`, or `error` events will be emitted,
but the `close` event may still be emitted.

#### openReadStream(entry, [callback])

`entry` must be an `Entry` object from this `ZipFile`.
`callback` gets `(err, readStream)`, where `readStream` is a `Readable Stream`.
If the entry is compressed (with a supported compression method),
the read stream provides the decompressed data.
If this zipfile is already closed (see `close()`), the `callback` will receive an `err`.

It's possible for the `readStream` to emit errors for several reasons.
For example, if zlib cannot decompress the data, the zlib error will be emitted from the `readStream`.
Two more error cases are if the decompressed data has too many or too few actual bytes
compared to the reported byte count from the entry's `uncompressedSize` field.
yauzl notices this false information and emits an error from the `readStream`
after some number of bytes have already been piped through the stream.

Because of this check, clients can always trust the `uncompressedSize` field in `Entry` objects.
Guarding against [zip bomb](http://en.wikipedia.org/wiki/Zip_bomb) attacks can be accomplished by
doing some heuristic checks on the size metadata and then watching out for the above errors.
Such heuristics are outside the scope of this library,
but enforcing the `uncompressedSize` is implemented here as a security feature.

#### close()

Causes all future calls to `openReadStream()` to fail,
and closes the fd after all streams created by `openReadStream()` have emitted their `end` events.
If this object's `end` event has not been emitted yet, this function causes undefined behavior.

If `autoClose` is `true` in the original `open()` or `fromFd()` call,
this function will be called automatically effectively in response to this object's `end` event.

#### isOpen

`Boolean`. `true` until `close()` is called; then it's `false`.

#### entryCount

`Number`. Total number of central directory records.

#### comment

`String`. Always decoded with `CP437` per the spec.

### Class: Entry

Objects of this class represent Central Directory Records.
Refer to the zipfile specification for more details about these fields.

These fields are of type `Number`:

 * `versionMadeBy`
 * `versionNeededToExtract`
 * `generalPurposeBitFlag`
 * `compressionMethod`
 * `lastModFileTime` (MS-DOS format, see `getLastModDateTime`)
 * `lastModFileDate` (MS-DOS format, see `getLastModDateTime`)
 * `crc32`
 * `compressedSize`
 * `uncompressedSize`
 * `fileNameLength` (bytes)
 * `extraFieldLength` (bytes)
 * `fileCommentLength` (bytes)
 * `internalFileAttributes`
 * `externalFileAttributes`
 * `relativeOffsetOfLocalHeader`

#### fileName

`String`.
Following the spec, the bytes for the file name are decoded with
`UTF-8` if `generalPurposeBitFlag & 0x800`, otherwise with `CP437`.

If `fileName` would contain unsafe characters, such as an absolute path or
a relative directory, yauzl emits an error instead of an entry.

#### extraFields

`Array` with each entry in the form `{id: id, data: data}`,
where `id` is a `Number` and `data` is a `Buffer`.
None of the extra fields are considered significant by this library.

#### comment

`String` decoded with the same charset as used for `fileName`.

#### getLastModDate()

Effectively implemented as:

```js
return dosDateTimeToDate(this.lastModFileDate, this.lastModFileTime);
```

## How to Avoid Crashing

When a malformed zipfile is encountered, the default behavior is to crash (throw an exception).
If you want to handle errors more gracefully than this,
be sure to do the following:

 * Provide `callback` parameters where they are allowed, and check the `err` parameter.
 * Attach a listener for the `error` event on any `ZipFile` object you get from `open()`, `fromFd()`, or `fromBuffer()`.
 * Attach a listener for the `error` event on any stream you get from `openReadStream()`.

## Limitations

### No Streaming Unzip API

Due to the design of the .zip file format, it's impossible to interpret a .zip file from start to finish
(such as from a readable stream) without sacrificing correctness.
The Central Directory, which is the authority on the contents of the .zip file, is at the end of a .zip file, not the beginning.
A streaming API would need to either buffer the entire .zip file to get to the Central Directory before interpreting anything
(defeating the purpose of a streaming interface), or rely on the Local File Headers which are interspersed through the .zip file.
However, the Local File Headers are explicitly denounced in the spec as being unreliable copies of the Central Directory,
so trusting them would be a violation of the spec.

Any library that offers a streaming unzip API must make one of the above two compromises,
which makes the library either dishonest or nonconformant (usually the latter).
This library insists on correctness and adherence to the spec, and so does not offer a streaming API.

### No Multi-Disk Archive Support

This library does not support multi-disk zip files.
The multi-disk fields in the zipfile spec were intended for a zip file to span multiple floppy disks,
which probably never happens now.
If the "number of this disk" field in the End of Central Directory Record is not `0`,
the `open()`, `fromFd()`, or `fromBuffer()` `callback` will receive an `err`.
By extension the following zip file fields are ignored by this library and not provided to clients:

 * Disk where central directory starts
 * Number of central directory records on this disk
 * Disk number where file starts

### No Encryption Support

Currently, the presence of encryption is not even checked,
and encrypted zip files will cause undefined behavior.

### Local File Headers Are Ignored

Many unzip libraries mistakenly read the Local File Header data in zip files.
This data is officially defined to be redundant with the Central Directory information,
and is not to be trusted.
Aside from checking the signature, yauzl ignores the content of the Local File Header.

### No CRC-32 Checking

This library provides the `crc32` field of `Entry` objects read from the Central Directory.
However, this field is not used for anything in this library.

### versionNeededToExtract Is Ignored

The field `versionNeededToExtract` is ignored,
because this library doesn't support the complete zip file spec at any version,

### No Support For Obscure Compression Methods

Regarding the `compressionMethod` field of `Entry` objects,
only method `0` (stored with no compression)
and method `8` (deflated) are supported.
Any of the other 15 official methods will cause the `openReadStream()` `callback` to receive an `err`.

### No ZIP64 Support

A ZIP64 file will probably cause undefined behavior.

### Data Descriptors Are Ignored

There may or may not be Data Descriptor sections in a zip file.
This library provides no support for finding or interpreting them.

### Archive Extra Data Record Is Ignored

There may or may not be an Archive Extra Data Record section in a zip file.
This library provides no support for finding or interpreting it.

### No Language Encoding Flag Support

Zip files officially support charset encodings other than CP437 and UTF-8,
but the zip file spec does not specify how it works.
This library makes no attempt to interpret the Language Encoding Flag.
