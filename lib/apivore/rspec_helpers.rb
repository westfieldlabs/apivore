require 'apivore/validator'
require 'apivore/all_routes_tested_validator'

module Apivore
  module RspecHelpers
    def validate(method, path, response_code, params = {})
      Validator.new(method, path, response_code, params)
    end

    def validate_all_paths
      AllRoutesTestedValidator.new
    end
  end
end
