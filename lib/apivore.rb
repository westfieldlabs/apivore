require 'apivore/rspec_builder'
require 'apivore/rspec_matchers'

module Apivore
  class Swagger < Hashie::Mash

    def validate
      case version
      when '2.0'
        schema = File.read(File.expand_path("../../data/swagger_2.0_schema.json", __FILE__))
      else
        raise "Unknown/unsupported Swagger version to validate against: #{version}"
      end
      JSON::Validator.fully_validate(schema, self)
    end

    def version
      swagger
    end

    def each_response(&block)
      paths.each do |path, path_data|
        path_data.each do |verb, method_data|
          method_data.responses.each do |response_code, response_data|
            block.call(path, verb, response_code, get_schema(response_data.schema))
          end
        end
      end
    end

    def get_schema(schema)
      ref = nil
      ref = schema['$ref'] if schema
      ref = schema.items['$ref'] if schema && schema.items
      definitions[ref.split('/').last] if ref
    end

  end

end
