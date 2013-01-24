# Yawpa

Yet Another Way to Parse Arguments is an argument-parsing library for Ruby.

## Features

- POSIX or non-POSIX mode (supports subcommands using POSIX mode)
- Options can require an arbitrary number of parameters
- Options can be defined with a range specifying the allowed number of parameters

## Installation

Add this line to your application's Gemfile:

    gem 'yawpa'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yawpa

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
