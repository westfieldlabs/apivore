require 'apivore/validator'
require 'apivore/all_documented_routes_tested'

module Apivore
  module RspecHelpers
    def validate(method, path, response_code, params = {})
      Validator.new(method, path, response_code, params)
    end

    def document_all_paths
      AllDocumentedRoutesTested.new
    end
  end
end
