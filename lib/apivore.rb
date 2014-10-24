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

    def paths(filter = nil)
      result = @json['paths'].collect { |p| Path.new(p, @base_path) }
      unless filter.nil?
        result.select! { |p| p.has_method?(filter) }
      end
      result
    end
  end

  class Path
    attr_reader :name, :full_path
    def initialize(path_data, base_path)
      @name = path_data.first
      @full_path = base_path + @name
      @method_data = path_data.last
    end

    def has_method?(method)
      @method_data.each { |m| return true if m.first == method }
      false
    end

    def has_model?(method, response = '200')
      unless @method_data[method]['responses'][response].nil?
        object = SchemaObject.new(@method_data[method]['responses'][response])
        object.has_model?
      else
        false
      end
    end

    def get_model(method, response = '200')
      object = SchemaObject.new(@method_data[method]['responses'][response])
      object.model
    end
  end

  class SchemaObject
    def initialize(schema)
       @body = schema
    end

    def has_model?
      # TODO: have this check references to definitions from the full Api Definition
      false
    end
  end
end

