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
      unless path[1][method]['responses'][response].nil?
        schema = path[1][method]['responses'][response]['schema']
        puts "DEBUG: #{schema}"
        schema != nil
      else
        # this path / method combination does not have a 200 response defined, therefore FAIL
        false
      end
    end

    def self.has_model?(path_method)
      # Currently this method only looks a 200 reponses models, if they exist
      unless path_method['responses']['200'].nil?
        path_method['responses']['200']['schema'] != nil
      else
        # this path method does not have a 200 response defined, therefore FAIL
        false
      end
    end
  end
end

