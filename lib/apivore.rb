require 'json'
require 'json-schema'
require 'apivore/rspec_matchers'

module Apivore
  class ApiDescription
    attr_reader :swagger_version
    def initialize(swagger)
      @json = JSON.parse(swagger)
      @swagger_version = @json['swagger']
      @apis = @json['apis']
      @base_path = @json['basePath']
    end

    def is_valid?(version)
      case version
      when '2.0'
        schema = File.read(File.expand_path("../../data/swagger_2.0_schema.json", __FILE__))
      else
        raise "Unknown/unsupported Swagger version to validate against: #{version}"
      end
      result = JSON::Validator.fully_validate(schema, @json)
      result == []
    end

    def paths()
      @json['paths']
    end

    def has_model?(path, method, response = '200')
      # path is the parsed json 'path' from the api description
      unless path[1][method]['responses'][response].nil?
        schema = path[1][method]['responses'][response]['schema']
        puts "DEBUG: #{schema}"
        schema != nil
      else
        # this path / method combination does not have a 200 response defined, therefore return false
        false
      end
    end

  end
end

