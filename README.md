# Zeiger

Zeiger is the German word for "pointer", "indicator", "index", "locator". This gem is built in the "index" sense : run

```
cd myproject
zeiger server
```

and this gem will create an in-memory index of all text in the filesystem subtree rooted in the current directory.

Query the index thus:

```
cd myproject
zeiger search "muppets"
```

This example returns one line for each line in your projects containing the word "muppets". Output is in the same format as `grep` (so you can hook it up with your emacs for quick project browsing).

## Installation

```
gem install 'zeiger'
```

This is built as a standalone commandline tool ; I don't have any use-cases for integrating it directly into a larger project. But if you do, I'm all ears.

## Usage

`zeiger server` runs the server and opens a unix filesystem socket called `zeiger-index` in the current directory.

`zeiger search "foo"` writes the query to the socket and displays the result

`zeiger files "xed"` asks for the list of filenames corresponding to the argument ("xed"). With no argument, return all filenames.

By default, Zeiger searches only in these subdirectories : %w{ app bin config lib spec test }, and excludes filenames matching these patterns: %w{ .gz$ .png$ .jpg$ .pdf$ }.

To override, create a file in your working directory with the following format:

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
  - .xcf$
  - .mpg$
```


## Contributing

1. Fork it ( https://github.com/conanite/zeiger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
