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

    def has_model_for?(path)
      # TODO: this needs work
      models = true
      # for swagger 2.0:
      path[1].each do |method, value|
        models &= !value['responses']['200']['schema']['items']['properties'].nil?
      end
      models
    end
  end
end

