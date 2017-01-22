module Apivore
  class RailsShim
    class << self
      def action_dispatch_request_args(path, params: {}, headers: {})
        if ActionPack::VERSION::MAJOR >= 5
          [path, params: params, headers: headers]
        else
          [path, params, headers]
        end
      end
    end
  end
end
