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
      if param =~ /^(-+)([^=]+)(=.+)?$/
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
          elsif nargs.class == Fixnum
            n_gathered = 0
            opts[param_key] = []
            if val
              opts[param_key] << val[1, val.length]
              n_gathered += 1
            end
            while n_gathered < nargs
              if i + 1 >= params.length
                raise InvalidArgumentsException.new("Not enough arguments supplied for option '#{param_name}'")
              end
              i += 1
              opts[param_key] << params[i]
              n_gathered += 1
            end
            if n_gathered == 1
              opts[param_key] = opts[param_key][0]
            end
          elsif nargs.class == Range
          end
        end
      else
        args << params[i]
      end
      i += 1
    end
    return [opts, args]
  end
end
