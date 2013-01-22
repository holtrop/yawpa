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
    opts = {}
    args = []
    i = 0
    while i < params.length
      param = params[i]
      if param =~ /^(--?)([^=]+)(?:=(.+))?$/
        leader, param_name, val = $1, $2, $3
        case leader.length
        when 2
          param_key = if options[param_name]
                        param_name
                      elsif options[param_name.to_sym]
                        param_name.to_sym
                      else
                        nil
                      end
          if param_key.nil?
            raise UnknownOptionException.new("Unknown option '#{param_name}'")
          end
          opt_config = options[param_key]
          nargs = opt_config[:nargs] || 0
          if nargs == 0
            opts[param_key] = true
          else
            nargs = (nargs..nargs) if nargs.class == Fixnum
            opts[param_key] = []
            opts[param_key] << val if val
            if opts[param_key].length < nargs.last
              gathered = _gather(i + 1, nargs.last - opts[param_key].length, params)
              i += gathered.length
              opts[param_key] += gathered
              if opts[param_key].length < nargs.first
                raise InvalidArgumentsException.new("Not enough arguments supplied for option '#{param_name}'")
              end
            end
            if opts[param_key].length == 1
              opts[param_key] = opts[param_key].first
            end
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
end
