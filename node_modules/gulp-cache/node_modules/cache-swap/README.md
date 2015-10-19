# cache-swap

[![NPM version](http://img.shields.io/npm/v/cache-swap.svg)](https://www.npmjs.com/package/cache-swap)
[![Build status](https://ci.appveyor.com/api/projects/status/98uvrob6ogl7noey?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/cache-swap)
[![Dependency Status](https://img.shields.io/david/jgable/cache-swap.svg?label=deps)](https://david-dm.org/jgable/cache-swap)
[![devDependency Status](https://img.shields.io/david/dev/jgable/cache-swap.svg?label=devDeps)](https://david-dm.org/jgable/cache-swap#info=devDependencies)

A lightweight file swap cache backed by temp files.

## Example

```javascript
var swap = new CacheSwap({
    cacheDirName: "HoganizeSwap"
  }),
  processTemplate = function(template, done) {
    var templateStr = template.content,
      templatePath = template.path,
      templateHash = files.shaIt(templateStr);

    swap.getCached("hoganize", templateHash, function(err, cached) {
      if(err) {
        return done(err);
      }

      var yeahbrotha,
        stringed;

      if(cached) {
        yeahbrotha = cached.contents;
        try {
          addToHoganized(yeahbrotha, templatePath);
        } catch(e){
          return done(e);
        }

        done();
      } else {
        yeahbrotha = self._compileTemplate(templateStr, templatePath);
        // Add the compiled template to the cache swap for next time.
        swap.addCached("hoganize", templateHash, yeahbrotha, function(err) {
          if(err) {
            return done(err);
          }

          try {
            addToHoganized(yeahbrotha, templatePath);
          } catch(e) {
            return done(e);
          }

          done();
        });
      }

    });
  };
```

## License

Licensed under the MIT License, Copyright 2013-2015 Jacob Gable
