require "yawpa/version"

# Example options configuration:
# {
#   version: {},
#   verbose: {short: 'v'},
#   get: {nargs: 1},
#   set: {nargs: 2},
# }
module Yawpa
  class UnknownOptionException < Exception; end
  class InvalidArgumentsException < Exception; end

  module_function
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
          raise UnknownOptionException.new("Unknown option '#{param_name}'")
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
            raise UnknownOptionException.new("Unknown option '-#{short_flags[short_idx]}'")
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
      result << params[index]
      index += 1
      num_indices_used += 1
      n_gathered += 1
    end
    if n_gathered < nargs.first
      raise InvalidArgumentsException.new("Not enough arguments supplied for option '#{param_key}'")
    end
    num_indices_used
  end

  def _massage_options(options)
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

  def _find_opt_config_by_short_name(options, short_name)
    options.each_pair do |k, v|
      return v if v[:short] == short_name
    end
    nil
  end
end
