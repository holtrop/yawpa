# Yet Another Way to Parse Arguments is an argument-parsing library for Ruby.
#
# Yawpa does not try to provide a fancy DSL.
# It does not require you to define a class or inherit from a class.
# it just provides a simple functional interface for parsing options,
# supporting subcommands and arbitrary numbers of arguments for each option.
#
# Features:
# - POSIX or non-POSIX mode (supports subcommands using POSIX mode)
# - Options can require an arbitrary number of parameters
# - Options can be defined with a range specifying the allowed number of
#   parameters
module Yawpa

  # gem version
  VERSION = "1.4.0"

  # Exception class raised when an unknown option is observed.
  class ArgumentParsingException < Exception; end

  class << self

    # Parse input parameters looking for options according to rules given in
    # flags.
    # Syntax:
    #   opts, args = parse(params, options, flags = {})
    #
    # An ArgumentParsingException will be raised if an unknown option is
    # observed or insufficient arguments are present for an option.
    #
    # Example +options+:
    #
    #   {
    #     version: nil,
    #     verbose: {short: 'v'},
    #     server: {nargs: (1..2)},
    #     username: {nargs: 1},
    #     password: {nargs: 1},
    #     color: :boolean,
    #     scan: {nargs: 1, multi: true},
    #   }
    #
    # The keys of the +options+ Hash can be either strings or symbols.
    #
    #
    # @param params [Array]
    #   List of program parameters to parse.
    # @param options [Hash]
    #   Hash containing the long option names as keys, and values containing
    #   special flags for the options as values (examples above).
    #   Possible values:
    #   +nil+:: No special flags for this option (equivalent to +{}+)
    #   +:boolean+::
    #     The option is a toggleable boolean option (equivalent to
    #     +{boolean: true}+)
    #   Hash::
    #     Possible option flags:
    #     - +:short+: specify a short option letter to associate with the long
    #       option
    #     - +:nargs+: specify an exact number or range of possible numbers of
    #       arguments to the option
    #     - +:boolean+: if true, specify that the option is a toggleable
    #       boolean option and allow a prefix of "no" to turn it off.
    #     - +:multi+: if true, instead of the last value specified for this
    #       option being returned, an Array of all values specified for this
    #       option will be returned, allowing the argument to appear multiple
    #       times in the argument list
    # @param flags [Hash]
    #   Optional flags dictating how {.parse} should do its job.
    # @option flags [Boolean] :posix_order
    #   Stop processing parameters when a non-option argument is seen.
    #   Set this to +true+ if you want to implement subcommands.
    #
    # @return [Array]
    #   Two-element array containing +opts+ and +args+ return values.
    #   +opts+::
    #     The returned +opts+ value will be a Hash with the observed
    #     options as keys and any option arguments as values.
    #   +args+::
    #     The returned +args+ will be an Array of the unprocessed
    #     parameters (if +:posix_order+ was passed in +flags+, this array might
    #     contain further options that were not processed after observing a
    #     non-option parameters).
    def parse(params, options, flags = {})
      options = _massage_options(options)
      opts = {}
      args = []
      i = 0
      while i < params.length
        param = params[i]
        if param =~ /^--([^=]+)(?:=(.+))?$/
          param_name, val = $1, $2
          bool_val = true
          if options[param_name].nil?
            if param_name =~ /^no(.*)$/
              test_param_name = $1
              if options[test_param_name]
                param_name = test_param_name
                bool_val = false
              end
            end
          end
          opt_config = options[param_name]
          raise ArgumentParsingException.new("Unknown option '#{param_name}'") unless opt_config
          param_key = opt_config[:key]
          if opt_config[:boolean]
            param_val = bool_val
          elsif opt_config[:nargs].last == 0
            param_val = true
          else
            param_val = []
            i += _gather(opt_config[:nargs], i + 1, params, val, param_key, param_val)
          end
          _record_opt_val(opts, opt_config, param_key, param_val)
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
              param_val = true
              _record_opt_val(opts, opt_config, param_key, param_val)
            else
              param_val = []
              i += _gather(opt_config[:nargs],
                           i + 1,
                           params,
                           short_flags[short_idx + 1, short_flags.length],
                           param_key,
                           param_val)
              _record_opt_val(opts, opt_config, param_key, param_val)
              break
            end
            short_idx += 1
          end
        elsif flags[:posix_order]
          args = params[i, params.length].map(&:dup)
          break
        else
          args << params[i].dup
        end
        i += 1
      end

      return [opts, args]
    end

    private

    def _record_opt_val(opts, opt_config, param_key, value)
      # Condense 1-element arrays of option values to just the element itself
      if value.is_a?(Array) and value.length == 1
        value = value.first
      end
      if opt_config[:multi]
        opts[param_key] ||= []
        opts[param_key] << value
      else
        opts[param_key] = value
      end
    end

    # Internal helper method to gather arguments for an option
    def _gather(nargs, start_idx, params, initial, param_key, result)
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
        result << params[index].dup
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
    def _massage_options(options)
      {}.tap do |newopts|
        options.each_pair do |k, v|
          v = {} if v.nil?
          v = {boolean: true} if v == :boolean
          newkey = k.to_s
          newopts[newkey] = {key: k}
          nargs = v[:nargs] || 0
          nargs = (nargs..nargs) if nargs.is_a?(Integer)
          newopts[newkey][:nargs] = nargs
          newopts[newkey][:short] = v[:short] || ''
          newopts[newkey][:boolean] = v[:boolean]
          newopts[newkey][:multi] = v[:multi]
        end
      end
    end

    # Internal helper method to find an option configuration by short name
    def _find_opt_config_by_short_name(options, short_name)
      options.each_pair do |k, v|
        return v if v[:short] == short_name
      end
      nil
    end

  end

end
