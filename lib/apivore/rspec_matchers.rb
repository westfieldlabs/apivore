require 'json-schema'
require 'rspec/expectations'

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

    matcher :be_consistent_with_master_swagger_docs do |master_swagger_uri|
      match do |body|
        @errors = []
        req = Faraday.new(master_swagger_uri).get("swagger.json")
        master_swagger = JSON.parse(req.body)
        our_swagger = JSON.parse(body)
        master_paths = master_swagger["paths"]
        our_paths = our_swagger["paths"]
        master_paths_segment = master_paths.slice(*our_paths.keys)
        expect(master_paths_segment).to eq(our_paths)
        master_definitions = master_swagger["definitions"]
        our_definitions = our_swagger["definitions"]
        master_definitions_segment = master_definitions.slice(*our_definitions.keys)
        # should fail here
        # TODO, better error messages!
        expect(master_definitions_segment).to eq(our_definitions)
        @errors.empty?
      end

      failure_message do
        @errors.join("\n")
      end
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
