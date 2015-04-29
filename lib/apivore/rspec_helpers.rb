require 'apivore/document'
require 'apivore/all_documented_routes_tested'

module Apivore
  module RspecHelpers
    def document(method, path, response_code, params = {})
      Document.new(method, path, response_code, params)
    end

    def document_all_paths
      AllDocumentedRoutesTested.new
    end
  end
end
