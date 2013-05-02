require "yawpa/version"

# Yet Another Way to Parse Arguments is an argument-parsing library for Ruby.
#
# Yawpa does not try to provide a fancy DSL.
# It does not require you to define a class or inherit from a class.
# it just provides a simple functional interface for parsing options,
# supporting subcommands and arbitrary numbers of arguments for each option.
#
# == Features
#
# - POSIX or non-POSIX mode (supports subcommands using POSIX mode)
# - Options can require an arbitrary number of parameters
# - Options can be defined with a range specifying the allowed number of parameters
module Yawpa
  # Exception class raised when an unknown option is observed
  class ArgumentParsingException < Exception; end

  module_function
  # :call-seq:
  #   opts, args = parse(params, options, flags = {})
  #
  # Parse input parameters looking for options according to rules given in flags
  #
  # - +params+ is the list of program parameters to parse.
  # - +options+ is a hash containing the long option names as keys, and hashes
  #   containing special flags for the options as values (example below).
  # - +flags+ is optional. It supports the following keys:
  #   - +:posix_order+: Stop processing parameters when a non-option is seen.
  #     Set this to +true+ if you want to implement subcommands.
  #
  # == Example +options+
  #
  #   {
  #     version: {},
  #     verbose: {short: 'v'},
  #     server: {nargs: (1..2)},
  #     username: {nargs: 1},
  #     password: {nargs: 1},
  #   }
  #
  # The keys of the +options+ hash can be either strings or symbols.
  #
  # Options that have no special flags should have an empty hash as the value.
  #
  # Possible option flags:
  # - +:short+: specify a short option letter to associate with the long option
  # - +:nargs+: specify an exact number or range of possible numbers of
  #   arguments to the option
  #
  # == Return values
  #
  # The returned +opts+ value will be a hash with the observed options as
  # keys and any option arguments as values.
  # The returned +args+ will be an array of the unprocessed parameters (if
  # +:posix_order+ was passed in +flags+, this array might contain further
  # options that were not processed after observing a non-option parameters.
  def parse(params, options, flags = {})
    options = _massage_options(options)
    opts = {}
    args = []
    i = 0
    while i < params.length
      param = params[i]
      if param =~ /^--([^=]+)(?:=(.+))?$/
        param_name, val = $1, $2
        if options[param_name].nil?
          raise ArgumentParsingException.new("Unknown option '#{param_name}'")
        end
        opt_config = options[param_name]
        param_key = opt_config[:key]
        if opt_config[:nargs].last == 0
          opts[param_key] = true
        else
          opts[param_key] = []
          i += _gather(opt_config[:nargs], i + 1, params, val, param_key, opts[param_key])
        end
      elsif param =~ /^-(.+)$/
        short_flags = $1
        short_idx = 0
        while short_idx < short_flags.length
          opt_config = _find_opt_config_by_short_name(options, short_flags[short_idx])
          if opt_config.nil?
            raise ArgumentParsingException.new("Unknown option '-#{short_flags[short_idx]}'")
          end
          param_key = opt_config[:key]
          if opt_config[:nargs].last == 0
            opts[param_key] = true
          else
            opts[param_key] = []
            i += _gather(opt_config[:nargs], i + 1, params, short_flags[short_idx + 1, short_flags.length], param_key, opts[param_key])
            break
          end
          short_idx += 1
        end
      elsif flags[:posix_order]
        args = params[i, params.length]
        break
      else
        args << params[i]
      end
      i += 1
    end

    # Condense 1-element arrays of option values to just the element itself
    opts.each_key do |k|
      if opts[k].class == Array and opts[k].length == 1
        opts[k] = opts[k].first
      end
    end

    return [opts, args]
  end

  # Internal helper method to gather arguments for an option
  def _gather(nargs, start_idx, params, initial, param_key, result) # :nodoc:
    n_gathered = 0
    if initial and initial != ''
      result << initial
      n_gathered += 1
    end
    num_indices_used = 0
    index = start_idx
    while n_gathered < nargs.last and
          index < params.length and
          params[index][0] != '-' do
      result << params[index]
      index += 1
      num_indices_used += 1
      n_gathered += 1
    end
    if n_gathered < nargs.first
      raise ArgumentParsingException.new("Not enough arguments supplied for option '#{param_key}'")
    end
    num_indices_used
  end

  # Internal helper method to format the options in a consistent format
  def _massage_options(options) # :nodoc:
    {}.tap do |newopts|
      options.each_pair do |k, v|
        newkey = k.to_s
        newopts[newkey] = {key: k}
        nargs = v[:nargs] || 0
        nargs = (nargs..nargs) if nargs.class == Fixnum
        newopts[newkey][:nargs] = nargs
        newopts[newkey][:short] = v[:short] || ''
      end
    end
  end

  # Internal helper method to find an option configuration by short name
  def _find_opt_config_by_short_name(options, short_name) # :nodoc:
    options.each_pair do |k, v|
      return v if v[:short] == short_name
    end
    nil
  end
end
