# Yawpa

Yet Another Way to Parse Arguments is an argument-parsing library for Ruby.

## Features

- POSIX or non-POSIX mode (supports subcommands using POSIX mode)
- Options can require an arbitrary number of parameters
- Options can be defined with a range specifying the allowed number of parameters

## Example 1

    require 'yawpa'

    options = {
      version: {},
      verbose: {short: 'v'},
      get: {nargs: 1},
      set: {nargs: 2},
    }
    opts, args = Yawpa.parse(ARGV, options)
    opts.each_pair do |opt, val|
    end

## Example 2

    require 'yawpa'

    options = {
      version: {},
      help: {short: 'h'},
    }
    opts, args = Yawpa.parse(ARGV, options, posix_order: true)
    if opts[:version]
      puts "my app, version 1.2.3"
    end
    if args[0] == 'subcommand'
      subcommand_options = {
        'server': {nargs: (1..2), short: 's'},
        'dst': {nargs: 1, short: 'd'},
      }
      opts, args = Yawpa.parse(args, subcommand_options)
    end

## Using Yawpa.parse()

    opts, args = Yawpa.parse(params, options, flags = {})

Parse input parameters looking for options according to rules given in flags

- `params` is the list of program parameters to parse.
- `options` is a hash containing the long option names as keys, and hashes
  containing special flags for the options as values (example below).
- `flags` is optional. It supports the following keys:
  - `:posix_order`: Stop processing parameters when a non-option is seen.
    Set this to `true` if you want to implement subcommands.

An ArgumentParsingException will be raised if an unknown option is observed
or insufficient arguments are present for an option.

### Example `options`

    {
      version: {},
      verbose: {short: 'v'},
      server: {nargs: (1..2)},
      username: {nargs: 1},
      password: {nargs: 1},
    }

The keys of the `options` hash can be either strings or symbols.

Options that have no special flags should have an empty hash as the value.

Possible option flags:
- `:short`: specify a short option letter to associate with the long option
- `:nargs`: specify an exact number or range of possible numbers of
  arguments to the option

### Return values

The returned `opts` value will be a hash with the observed options as
keys and any option arguments as values.
The returned `args` will be an array of the unprocessed parameters (if
`:posix_order` was passed in `flags`, this array might contain further
options that were not processed after observing a non-option parameters.
