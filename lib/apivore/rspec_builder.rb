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
      !mappings[path].nil?
    end

    def has_method_at_path?(path, method)
      !mappings[path][method].nil?
    end

    def has_response_code_for_path?(path, method, code)
      !mappings[path][method][code.to_s].nil?
    end

    def has_matching_document_for(path, method, code, body)
      JSON::Validator.fully_validate(
        swagger, body, fragment: fragment(path, method, code), strict: true
      )
    end

    def fragment(path, method, code)
      mappings[path][method][code]
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

  end

  class Document
    include ::ActionDispatch::Integration::Runner

    attr_reader :method, :path, :expected_response_code, :params

    def initialize(method, path, expected_response_code, params = {})
      @method = method.to_s
      @path = path.to_s
      @expected_response_code = expected_response_code.to_i
    end

    def matches?(swagger_checker)
      pre_checks(swagger_checker)

      unless has_errors?
        send(method, swagger_checker.base_path + path)
        post_checks(swagger_checker)
      end

      !has_errors?
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
        errors << "Swagger doc: #{swagger_checker.swagger_path} does not have a documented response code of #{expected_response_code} at path #{path}"
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
    # extend ::RSpec::Matchers::DSL

    # matcher :document do |method, path, response_code|
    #   extend ActionDispatch::Integration
    #   include ActionDispatch::Integration
    #   match { |subject|
    #     send(method, path)
    #     actual == expected
    #   }
    # end
    # include ::RSpec::Matchers
    # include ActionDispatch::Integration


    # attr_accessor :fragment, :response
    # attr_reader :path, :response_code, :swagger, :http_method
    # def initialize(path, http_method, response_code, swagger)
    #   @swagger = swagger
    #   @http_method = http_method
    #   @path = path
    #   @response_code = response_code
    #   puts path
    # end
    #
    # def correct?
    #   expect(response.status).to be(response_code.to_i)#, "expected status #{response_code}, got #{response.status}: #{response.body}"
    #   if fragment
    #     expect(response.body).to conform_to_the_documented_model_for(swagger, fragment)
    #   end
    #   true
    # end
  end

  module RspecBuilder
    include Apivore::RspecMatchers
    include ActionDispatch::Integration
    include RSpec::Mocks::ExampleMethods

    @@setups ||= {}

    @@master_swagger_uri = nil
    def document(method, path, response_code)
      Document.new(method, path, response_code)
    end
    # Setup tests against a combination of path, method, and response.
    # - *keys -> A combination of path, method, and/or response. Blank '' for base setup.
    # - &block -> Code block to execute to setup the test. A hash of path subsitution parameters can be returned if required.
    # All matching code blocks are executed, and substitution parameters are merged in order of specificity.
    def apivore_setup(path, method, response_code = 200, &block)
      response_code = response_code.to_s
      # @@setups[keys.join] = block
      describe "path #{path} method #{method} response #{response_code}" do
        it "responds with the specified models" do
          setup_data = block.call
          setup_data = {} unless setup_data.is_a? Hash
          # e.g., get(full_path)
          apivore_request(path, method, response_code, setup_data)
          expect(response).to have_http_status(response_code), "expected #{response_code} array, got #{response.status}: #{response.body}"
        end
      end
    end

    def swagger_description(path, method, response_code, params = {}, &block)
      response_code = response_code.to_s
      describe "path #{path} method #{method} response #{response_code}" do
        subject { RspecTestThing.new(path, method, response_code, @@swagger) }
        before do
          apivore_request(path, method, response_code, params)
          subject.response = response
          expect(response).to have_http_status(response_code)#, "expected status #{response_code}, got #{response.status}: #{response.body}"
        end
        example(&block)

        #  do
        #   apivore_request(path, method, response_code, {})
        #
        #   subject.response = response
        #   instance_eval("is_expected.to be_correct", file_name, line_number)
        # end
      end
    end

    def apivore_request(path, method, response_code, setup_data)
      mapped_path = @@mappings[path]
      raise "undocumented path: #{path}" if mapped_path.nil?
      mapped_method = mapped_path[method]
      raise "undocumented method: #{method} for path: #{path}" if mapped_method.nil?
      subject.fragment = mapped_method.delete(response_code)
      full_path = apivore_build_path(@@swagger.base_path + path, setup_data)
      # Remove the path we are about to test
      if mapped_method.size == 0
        mapped_path.delete(method)
        if mapped_path.size == 0
          @@mappings.delete(path)
        end
      end

      begin
        send(method, full_path, setup_data['_data'] || {}, setup_data['_headers'] || {})
      rescue
        raise "Unable to #{method} #{full_path} -- invalid response from server: #{$!}."
      end
    end

    def get_apivore_setup(path, method, response)
      keys_to_search = [
        '', # base setup key
        response,
        method,
        path,
        method + response,
        path + response,
        path + method,
        path + method + response
      ]
      final_result = {}
      keys_to_search.each do |k|
        setup = @@setups[k]
        if setup
          result = instance_eval &setup
          final_result.merge!(result) if result.is_a?(Hash)
        end
      end
      final_result
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

    def apivore_check_consistency_with_swagger_at(uri, current_service = nil)
      @@current_service = current_service
      @@master_swagger_uri = uri
    end

    def apivore_swagger(swagger_path)
      session = ActionDispatch::Integration::Session.new(Rails.application)
      begin
        session.get swagger_path
      rescue
        # TODO: make this fail inside rspec test execution rather than immediately raise an exception.
        # ALSO, handle other scenarios where we can't get a response to generate tests, e.g 500s, invalid formats etc
        raise "Unable to perform GET request for swagger json: #{swagger_path} - #{$!}."
      end
      Apivore::Swagger.new JSON.parse(session.response.body)
    end

    def all_done
      # after do
        expect(@@mappings).to eql({}), "Paths have not been documented"
      # end
    end

    def validate_against(swagger_path)
      describe "swagger documentation" do
        before { get swagger_path }
        subject { body }
        it { should be_valid_swagger }
        it { should have_models_for_all_get_endpoints }
        if @@master_swagger_uri
          req = Net::HTTP.get(@@master_swagger_uri, "/swagger.json")
          master_swagger = JSON.parse(req)
          it { should be_consistent_with_swagger_definitions master_swagger, @@current_service }
        end
      end

      @@swagger = apivore_swagger(swagger_path)

      @@mappings = {}
      @@swagger.each_response do |path, method, response_code, fragment|
        @@mappings[path] ||= {}
        @@mappings[path][method] ||= {}
        raise "duplicate" unless @@mappings[path][method][response_code].nil?
        @@mappings[path][method][response_code] = fragment
      end
    end

    def ensure_paths_are_tested
      context "nested so it runs after" do
        it "checks all the things" do
          all_done
        end
      end
    end

  end
end
