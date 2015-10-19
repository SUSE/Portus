### try-json-parse

Just like `JSON.parse()`, except it returns `undefined` instead of throwing an error for invalid JSON.

### Usage

```js
var JSONparse = require('./index'),
    assert    = require('assert'),
    fs        = require('fs');

fs.readFile(__dirname + '/package.json', function(err, content) {
  var pkgJson;

  if (err) { throw err; }

  pkgJson = JSONparse(content);
  assert.equal(pkgJson.name, 'try-json-parse');
  assert(JSONparse(fs.readFileSync(__filename)) === undefined);
});
```

### Motivation

Got tired of writing try {} catch {}.

### License

MIT
