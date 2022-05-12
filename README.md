# &#x261E; Zeiger

Zeiger is the German word for "pointer", "indicator", "index", "locator". This gem is built in the "index" sense. To install,

```
gem install zeiger
```

In a terminal, run

```
zeiger server
```

Zeiger will open a unix-socket under `/tmp` and listen for search and file-list requests. Run this in a terminal:

```
cd myproject
zeiger search "muppets"
```

(Replace "myproject" with something meaningful!)

Zeiger will index the current directory if it is not already indexed, then search for lines containing "muppets". Output is in the same format as `grep` (so you can hook it up with your emacs for quick project browsing).

Zeiger will rescan files in the current directory every ten seconds (configurable) so the index is mostly up-to-date.



## Usage

`zeiger server` runs the server and opens a unix filesystem socket called `/tmp/zeiger-index`

`zeiger search "foo"` writes the query to the socket and displays the result

`zeiger files "xed"` asks for the list of filenames corresponding to the argument ("xed"). With no argument, return all filenames. Files are sorted by length of filename. This sounds odd, but works nicely with 'completing-read in emacs: you will find the file you want in fewer keystrokes.

By default, Zeiger searches only in these subdirectories : `%w{ app bin config lib spec test }`, and excludes filenames matching these patterns: `%w{ .gz$ .png$ .jpg$ .pdf$ }`.

To override, create a file called `.zeiger.yml` in your project root with the following format:

```yaml
search:
  - bin
  - lib
  - config.rb
ignore:
  - .gz$
  - .png$
  - .gif$
  - .zip$
  - .jpg$
  - .ico$
  - .xcf$
  - .mpg$
```

You should change the contents to suit your indexing needs. The `search` key is a list of regexps, zeiger will index only those files whose name matches at least one of these regexps. The `ignore` key is likewise a list of regexps, zeiger will not index any file whose name matches any of these regexps. The `ignore` rule supercedes the `search` rule.

When you invoke `zeiger search ...` or `zeiger files ...`, zeiger will consider whether an index already exists for the current directory. If not, and the current directory is a project root, it will create an index for the current directory. If there is no index, and the current directory is not a project root, it moves up one directory and tries again.

Zeiger considers a project root any directory containing any one of the following: `%w{ .zeiger.yml .git .hg Makefile Rakefile Gemfile build.xml }` (see `ROOT_FILES` constant in `index.rb`)

## TODO

Use `Listen` gem instead of manual filesystem scan

## Contributing

1. Fork it ( https://github.com/conanite/zeiger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
