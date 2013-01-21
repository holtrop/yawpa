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
      if param[0] != '-'
        args << params[i]
      else
        opt_config = options[param] || options[param.to_sym]
        raise UnknownOptionException.new("Unknown option '#{param}'") if opt_config.nil?
      end
      i += 1
    end
    return [opts, args]
  end
end
