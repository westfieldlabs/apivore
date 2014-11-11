require 'json-schema'

module Apivore
  module RspecMatchers
    extend RSpec::Matchers::DSL
    matcher :be_valid_swagger do |version|
      match do |body|
        @api_description = Swagger.new(JSON.parse(body))
        @api_description.validate == []
      end

      failure_message do |body|
        msg = "The document fails to validate as Swagger #{@api_description.version}:\n\n"
        msg += @api_description.validate.join("\n\n")
        msg
      end
    end

    matcher :have_models_for_all_get_endpoints do
      match do |body|
        @errors = []
        swagger = Swagger.new(JSON.parse(body))
        swagger.each_response do |path, method, response_code, schema|
          if method == 'get' && !schema
            @errors << "Unable to find a valid model for #{path} get #{response_code} response."
          end
        end
        @errors.empty?
      end

      failure_message do
        @errors.join("\n")
      end
    end

    matcher :conform_to_the_documented_model_for do |swagger, fragment|
      match do |body|
        body = JSON.parse(body)
        # @errors = JSON::Validator.fully_validate(swagger, body, fragment: fragment, strict: true)
        @errors = JSON::Validator.fully_validate(fragment, body, strict: true, validate_schema: true, version: 'draft4')
        @errors.empty?
      end

      failure_message do |body|
        @errors.join("\n")
      end
    end
  end
end
