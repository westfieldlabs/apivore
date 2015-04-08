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

    def base_path
      self['basePath'] || ''
    end

    def each_response(&block)
      paths.each do |path, path_data|
        path_data.each do |verb, method_data|
          raise "No responses found in swagger for path '#{path}', method #{verb}: #{method_data.inspect}" if method_data.responses.nil?
          method_data.responses.each do |response_code, response_data|
            schema_location = nil
            if response_data.schema
              schema_location = Fragment.new ['#', 'paths', path, verb, 'responses', response_code, 'schema']
            end
            block.call(path, verb, response_code, schema_location)
          end
        end
      end
    end
  end

  # This is a workaround for json-schema's fragment validation which does not allow paths to contain forward slashes
  #  current json-schema attempts to split('/') on a string path to produce an array.
  class Fragment < Array
    def split(options = nil)
      self
    end
  end
end
