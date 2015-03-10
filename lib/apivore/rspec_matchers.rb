require 'json-schema'
require 'rspec/expectations'
require 'net/http'

module Apivore
  module RspecMatchers
    extend RSpec::Matchers::DSL
    matcher :be_valid_swagger do |version|
      match do |body|
        @api_description = Swagger.new(JSON.parse(body))
        @api_description.validate.empty?
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

    matcher :be_consistent_with_swagger_definitions do |master_swagger, current_service|

      attr_reader :actual, :expected

      match do |body|
        our_swagger = JSON.parse(body)
        master_definitions = master_swagger["definitions"].transform_values do |definition|
          # 'x-services' is added by api.westfield.io - services shouldn't need to define it
          if [current_service] == definition['x-services']
            definition.tap{|d|d.delete 'x-services'}
          else
            definition.tap{|d|d.delete 'x-services'}
          end
        end.compact
        our_definitions = our_swagger["definitions"]

        @actual = our_definitions.slice(*master_definitions.keys)
        @expected = master_definitions.slice(*our_definitions.keys)
        @actual == @expected
      end

      diffable
    end

    matcher :conform_to_the_documented_model_for do |swagger, fragment|
      match do |body|
        body = JSON.parse(body)
        @errors = JSON::Validator.fully_validate(swagger, body, fragment: fragment, strict: true)
        @errors.empty?
      end

      failure_message do |body|
        @errors.map { |e| e.gsub(/^The property|in schema.*$/,'') }.join("\n")
      end
    end
  end
end
