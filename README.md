# Yawpa

Yet Another Way to Parse Arguments is an argument-parsing library for Ruby.

[![Gem Version](https://badge.fury.io/rb/yawpa.png)](http://badge.fury.io/rb/yawpa)

## Features

- POSIX or non-POSIX mode (supports subcommands using POSIX mode)
- Options can require an arbitrary number of parameters
- Options can be defined with a range specifying the allowed number of parameters

## Usage

Yawpa can be used from another Ruby gem as a regular gem dependency, by adding
a dependency on the "yawpa" gem at a particular version.
For example:

```ruby
  gem.add_dependency "yawpa", "~> 1.3"
```

Yawpa can also be used by simply copying the contents of the one source file
into any project that desires to use it.
This can be useful if you desire to avoid having any external dependencies, or
if you are producing a redistributable standalone script.

## Example 1

```ruby
require "yawpa"

options = {
  version: {},
  verbose: {short: "v"},
  get: {nargs: 1},
  set: {nargs: 2},
}
opts, args = Yawpa.parse(ARGV, options)
opts.each_pair do |opt, val|
end
```

## Example 2

```ruby
require "yawpa"

options = {
  version: {},
  help: {short: "h"},
}
opts, args = Yawpa.parse(ARGV, options, posix_order: true)
if opts[:version]
  puts "my app, version 1.2.3"
end
if args[0] == "subcommand"
  subcommand_options = {
    "server": {nargs: (1..2), short: "s"},
    "dst": {nargs: 1, short: "d"},
  }
  opts, args = Yawpa.parse(args, subcommand_options)
end
```

## Using Yawpa.parse()

```ruby
opts, args = Yawpa.parse(params, options, flags = {})
```

Parse input parameters looking for options according to rules given in flags

- `params` is the list of program parameters to parse.
- `options` is a hash containing the long option names as keys, and hashes
  containing special flags for the options as values (example below).
  Possible values:
  - `nil`: No special flags for this option (equivalent to `{}`)
  - `:boolean`: The option is a toggleable boolean option (equivalent to
    `{boolean: true}`)
  - `Hash`: Possible option flags:
    - `:short`: specify a short option letter to associate with the long option
    - `:nargs`: specify an exact number or range of possible numbers of
      arguments to the option
    - `:boolean`: if true, specify that the option is a toggleable boolean
      option and allow a prefix of "no" to turn it off.
- `flags` is optional. It supports the following keys:
  - `:posix_order`: Stop processing parameters when a non-option is seen.
    Set this to `true` if you want to implement subcommands.

An ArgumentParsingException will be raised if an unknown option is observed
or insufficient arguments are present for an option.

### Example `options`

```ruby
{
  version: nil,
  verbose: {short: 'v'},
  server: {nargs: (1..2)},
  username: {nargs: 1},
  password: {nargs: 1},
  color: :boolean,
}
```

The keys of the `options` hash can be either strings or symbols.

Possible option flags:

- `:short`: specify a short option letter to associate with the long option
- `:nargs`: specify an exact number or range of possible numbers of
  arguments to the option
- `:boolean`: if true, specify that the option is a toggleable boolean
  option and allow a prefix of "no" to turn it off.

### Return values

The returned `opts` value will be a hash with the observed options as
keys and any option arguments as values.
The returned `args` will be an array of the unprocessed parameters (if
`:posix_order` was passed in `flags`, this array might contain further
options that were not processed after observing a non-option parameters).

## Release Notes

### v1.2.0

- Always return non-frozen strings

### v1.1.0

- Add `:boolean` option flag.
- Support `nil` or `:boolean` as shortcut option configuration values.
- Update documentation to YARD.
- Update specs to RSpec 3.

### v1.0.0

- Initial Release
