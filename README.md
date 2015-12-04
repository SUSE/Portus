## suse.github.io/Portus

The `gh-pages` branch contains the code of the web site of Portus. It has been
built with [Github Pages](https://pages.github.com/). You can also get your
hands dirty with this locally. Since this is built on top of
[Jekyll](http://jekyllrb.com/), you just have to type the following:

```
$ bundle
$ bundle exec jekyll serve
```

## Adding a new documentation page

The documentation follows the `post` layout. This layout is used in combination
with [Jekyll Collections](http://jekyllrb.com/docs/collections/). We have three
collections:

- `_features`: the documentation for a feature.
- `_docs`: a page explaining a general topic (e.g. configuring Portus).
- `_setups`: a step-by-step guide of a deployment method for Portus.

Each page of a Jekyll Collection has some headers specified in YAML format. In
our case we have the following headers:

- **layout**: set it to `post`.
- **title**: the short title for the page. This will be displayed on the left
sidebar.
- **longtitle**: a longer explanation for the page. This is not used for the
`_setups` collection. It will be shown in the `/features.html` and in the
`/documentation.html` pages.
- **order**: a numerical value stating the order of the page relative to the
rest of the pages of the collection. This parameter is used when displaying
each page in a list.

Therefore, when you want to create a new documentation page, you have to think
about in which collection does it fall, and then create the document with the
proper headers. After that, you can write you page in Markdown format.

## Editing the assets

If you are modifiying Less, JS or images in the `/assets` folder, you need to
run Gulp in your console in order to preprocess CSS, minify JS and compress
the images. All you need to do is type the following:

    $ ./node_modules/gulp/bin/gulp.js

After that, you will have the site available at `localhost:4000`.

Note that this command will take care of the `build` directory, which is the
one used by the finally rendered HTML page. Therefore, do *not* add a new
asset into the `build` directory manually. Instead, do it on the `/assets` one
and let Gulp handle it for you. Also note that you have to add into git both
versions of assets files.

## Tips and tricks when writing new pages

### Relative links

Referencing another document is pretty easy, but there are some subtleties:

- If you are referencing an indivial page, you have to use its `.html` name
  instead of its `.md` name.
- If you are referencing a page that is contained in a collection, the path is:
  - Doc: `/docs/<name-document>.html`.
  - Setup: `/docs/setups/<name-document>.html`.
  - Feature: `/features/<name-document>.html`.
- When referencing a title, you have to first write the URL to the document,
  and then use the anchor related to it. For example, if the title is
  `The Catalog API`, then the anchor to be appended to the name of the document
  is: `#the-catalog-api`.

Last but not least, images work in a similar way but they have `/build`
prepended to their path. This is because Gulp will put the generated assets
inside of this `build` directory.

## Licensing

Licensed under the Apache License, Version 2.0. See
[LICENSE](https://github.com/SUSE/Portus/blob/master/LICENSE) for the full
license text.

**Attributions**

Background picture by
[Skitter Photo](http://www.freepik.es/index.php?goto=41&idd=759003&url=aHR0cDovL3NraXR0ZXJwaG90by5jb20vP3BvcnRmb2xpbz1qZXR0eS1ieS1uaWdodA==#).
