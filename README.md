## port.us.org

The `gh-pages` branch contains the code of the web site of Portus, but it's
built out of the contents of this branch. In order to deploy from this branch to
`gh-pages`, you have to execute:

```
$ ./script/deploy.sh
```

As a developer, you don't have to care about all this: the only thing you need
to know is that you have to work by targeting this branch instead of
`gh-pages`.

This site is built with [Jekyll](http://jekyllrb.com/), so in order to get your
hands dirty you just have to type the following:

```
$ bundle
$ bundle exec jekyll serve
```

After executing this, the site will be available at
`http://localhost:4000`. Moreover, for the assets you need
[yarn](https://yarnpkg.com/lang/en/). Simply run:

```
$ yarn
```

This will download all the dependencies for the assets.

## Adding a new documentation page

The documentation follows the `default` layout. This layout is used in
combination with [Jekyll Collections](http://jekyllrb.com/docs/collections/). We
have three collections:

- `_features`: the documentation for a feature.
- `_docs`: a page explaining a general topic (e.g. configuring Portus).
- `_setups`: a step-by-step guide of a deployment method for Portus.

Each page of a Jekyll Collection has some headers specified in YAML format. In
our case we have the following headers:

- **layout**: set it to `default`.
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
proper headers. After that, you can write your page in Markdown format.

## Adding a new blog post

Since we are using Jekyll, blog posts are stored in the `_posts` directory, and
the files are formatted like `yyyy-mm-dd-title.md`. Each blogpost has the
following metadata:

- `title` & `subtitle`: the title and the subtitle of the blog post.
- `author`: the author publishing the post.
- `layout`: should be set to `blogpost`.

Once you are set, then you can write your blog post in plain markdown. The style
for blog posts have been adapted from
[rootco.de-web](https://github.com/sysrich/rootco.de-web).

## Editing the assets

We are using [SASS/SCSS](http://sass-lang.com/) for the stylesheets. This is
automatically rendered by Jekyll if you follow these conventions:

- The main scss file is in the `stylesheets` directory (and the file has to
  start with `---`). From there you import the partials and you can add some
  additional style code.
- Partials are stored in the `stylesheets/partials` directory. The name of a
  partial has to start with an underscore, and they can be imported with a
  simple `@import "partial";` statement from the main file.
- Vendor CSS has been stored in `stylesheets/vendor`.

When you modify any of these files, Jekyll will notice it and it will rebuild
the `portus.css` final stylesheet.

For the Javascript files, as mentioned earlier, you need Yarn. After downloading
all dependencies, you can perform:

```
$ yarn run webpack
```

This will run `webpack` with the `--watch` flag, so if you modify any file, it
will automatically get built.

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

## Licensing

Licensed under the Apache License, Version 2.0. See
[LICENSE](https://github.com/SUSE/Portus/blob/master/LICENSE) for the full
license text.
