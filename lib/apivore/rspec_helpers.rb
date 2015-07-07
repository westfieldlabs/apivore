require 'apivore/validator'
require 'apivore/all_routes_tested_validator'
require 'apivore/custom_schema_validator'

module Apivore
  module RspecHelpers
    def validate(method, path, response_code, params = {})
      Validator.new(method, path, response_code, params)
    end

    def conform_to(custom_schema)
      CustomSchemaValidator.new(custom_schema)
    end

    def validate_all_paths
      AllRoutesTestedValidator.new
    end
  end
end
