require 'apivore/rspec_matchers'
require 'action_controller'
require 'action_dispatch'
require 'rspec/mocks'
require 'hashie'
require 'pry'
require 'rspec/expectations'

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

  class Document
    include ::ActionDispatch::Integration::Runner

    attr_reader :method, :path, :expected_response_code, :params

    def initialize(method, path, expected_response_code, params = {})
      @method = method.to_s
      @path = path.to_s
      @params = params
      @expected_response_code = expected_response_code.to_i
    end

    def matches?(swagger_checker)
      pre_checks(swagger_checker)

      unless has_errors?
        send(method, apivore_build_path(swagger_checker.base_path + path, params))
        post_checks(swagger_checker)
        swagger_checker.remove_tested_end_point_response(path, method, expected_response_code)
      end

      !has_errors?
    end

    def apivore_build_path(path, data)
      path.scan(/\{([^\}]*)\}/).each do |param|
        key = param.first
        if data && data[key]
          path = path.gsub "{#{key}}", data[key].to_s
        else
          raise URI::InvalidURIError, "No substitution data found for {#{key}} to test the path #{path}.\nAdd it via an:\n  apivore_setup '<path>', '<method>', '<response>' do\n    { '#{key}' => <value> }\n  end\nblock in your specs.", caller
        end
      end
      path + (data['_query_string'] ? "?#{data['_query_string']}" : '')
    end


    def pre_checks(swagger_checker)
      check_request_path(swagger_checker)
    end

    def post_checks(swagger_checker)
      check_status_code
      check_response_is_valid(swagger_checker) unless has_errors?
    end

    def check_request_path(swagger_checker)
      if !swagger_checker.has_path?(path)
        errors << "Swagger doc: #{swagger_checker.swagger_path} does not have a documented path for #{path}"
      elsif !swagger_checker.has_method_at_path?(path, method)
        errors << "Swagger doc: #{swagger_checker.swagger_path} does not have a documented path for #{method} #{path}"
      elsif !swagger_checker.has_response_code_for_path?(path, method, expected_response_code)
        errors << "Swagger doc: #{swagger_checker.swagger_path} does not have a documented response code of #{expected_response_code} at path #{method} #{path}"
      end
    end

    def check_status_code
      if response.status != expected_response_code
        errors << "Path #{path} did not respond with expected status code. Expected #{expected_response_code} got #{response.status}"
      end
    end

    def check_response_is_valid(swagger_checker)
      errors = swagger_checker.has_matching_document_for(path, method, response.status, response_body)
      unless errors.empty?
        errors.concat!(errors)
      end
    end

    def response_body
      JSON.parse(response.body) unless response.body.blank?
    end

    def has_errors?
      !errors.empty?
    end

    def failure_message
      errors.join(" ")
    end

    def errors
      @errors ||= []
    end

    # Required by ActionDispatch::Integration::Runner
    def app
      ::Rails.application
    end
  end

  module RspecHelpers
    def document(method, path, response_code, params = {})
      Document.new(method, path, response_code, params)
    end

    def document_all_paths
      AllDocumentedRoutesTested.new
    end
  end

  class AllDocumentedRoutesTested

    def matches?(swagger_checker)
      @errors = []
      swagger_checker.mappings.each do |path, methods|
        methods.each do |method, codes|
          codes.each do |code|
            @errors << "#{method} #{path} is undocumented for response codes #{code}"
          end
        end
      end

      @errors.empty?
    end

    def description
      "have tested all documented routes"
    end

    def failure_message
      @errors.join("\n")
    end
  end

  module RspecBuilder

  end
end
