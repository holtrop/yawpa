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

  module_function
  def parse(params, options)
    opts = {}
    args = []
    i = 0
    while i < params.length
      param = params[i]
      if param =~ /^(-+)(.+)$/
        case $1.length
        when 2
          param_key = if options[$2]
                        $2
                      elsif options[$2.to_sym]
                        $2.to_sym
                      else
                        nil
                      end
          if param_key.nil?
            raise UnknownOptionException.new("Unknown option '#{param}'")
          end
          opt_config = options[param_key]
          nargs = opt_config[:nargs] || 0
          if nargs == 0
            opts[param_key] = true
          elsif nargs.class == FixNum
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
