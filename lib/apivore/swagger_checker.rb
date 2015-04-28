module Apivore
  class SwaggerChecker
    PATH_TO_CHECKER_MAP = {}

    def self.instance_for(path)
      PATH_TO_CHECKER_MAP[path] ||= new(path)
    end

    def has_path?(path)
      mappings.has_key?(path)
    end

    def has_method_at_path?(path, method)
      mappings[path].has_key?(method)
    end

    def has_response_code_for_path?(path, method, code)
      mappings[path][method].has_key?(code.to_s)
    end

    def has_matching_document_for(path, method, code, body)
      JSON::Validator.fully_validate(
        swagger, body, fragment: fragment(path, method, code), strict: true
      )
    end

    def fragment(path, method, code)
      mappings[path][method][code]
    end

    def remove_tested_end_point_response(path, method, code)
      mappings[path][method].delete(code.to_s)
      if mappings[path][method].size == 0
        mappings[path].delete(method)
        if mappings[path].size == 0
          mappings.delete(path)
        end
      end
    end

    def base_path
      @swagger.base_path
    end

    attr_reader :swagger_path, :mappings, :swagger

    private

    def initialize(swagger_path)
      @swagger_path = swagger_path
      @swagger = apivore_swagger(swagger_path)

      @mappings = {}
      @swagger.each_response do |path, method, response_code, fragment|
        @mappings[path] ||= {}
        @mappings[path][method] ||= {}
        raise "duplicate" unless @mappings[path][method][response_code].nil?
        @mappings[path][method][response_code] = fragment
      end
    end

    def apivore_swagger(swagger_path)
      session = ActionDispatch::Integration::Session.new(Rails.application)
      begin
        session.get swagger_path
        # get swagger_path
      rescue
        # TODO: make this fail inside rspec test execution rather than immediately raise an exception.
        # ALSO, handle other scenarios where we can't get a response to generate tests, e.g 500s, invalid formats etc
        raise "Unable to perform GET request for swagger json: #{swagger_path} - #{$!}."
      end
      Apivore::Swagger.new JSON.parse(session.response.body)
    end
  end
end
