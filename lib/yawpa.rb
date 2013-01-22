require "yawpa/version"

# Example options configuration:
# {
#   version: {},
#   verbose: {aliases: ['-v']},
#   get: {nargs: 1},
#   set: {nargs: 2},
# }
module Yawpa
  class UnknownOptionException < Exception; end
  class InvalidArgumentsException < Exception; end

  module_function
  def parse(params, options)
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
          opts[param_key] << val if val
          if opts[param_key].length < opt_config[:nargs].last
            gathered = _gather(i + 1, opt_config[:nargs].last - opts[param_key].length, params)
            i += gathered.length
            opts[param_key] += gathered
            if opts[param_key].length < opt_config[:nargs].first
              raise InvalidArgumentsException.new("Not enough arguments supplied for option '#{param_name}'")
            end
          end
          if opts[param_key].length == 1
            opts[param_key] = opts[param_key].first
          end
        end
      else
        args << params[i]
      end
      i += 1
    end
    return [opts, args]
  end

  def _gather(start_idx, max, params)
    result = []
    index = start_idx
    loop do
      break if index >= params.length
      break if params[index][0] == '-'
      result << params[index]
      index += 1
      break if result.length == max
    end
    result
  end

  def _massage_options(options)
    {}.tap do |newopts|
      options.each_pair do |k, v|
        newkey = k.to_s
        newopts[newkey] = {key: k}
        nargs = v[:nargs] || 0
        nargs = (nargs..nargs) if nargs.class == Fixnum
        newopts[newkey][:nargs] = nargs
      end
    end
  end
end
