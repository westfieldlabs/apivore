require 'apivore/rspec_builder'
require 'apivore/rspec_matchers'

module Apivore
  class ApiDescription < Hashie::Mash

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
            block.call(path, verb, response_code, get_schema(definitions))
          end
        end
      end
    end

    def get_schema(definitions)
      ref = nil
      if schema && schema.type
        ref = schema.items['$ref']
      elsif schema
        ref = schema['$ref']
      end
      definitions[ref.split('/').last] if ref
    end

  end

end
