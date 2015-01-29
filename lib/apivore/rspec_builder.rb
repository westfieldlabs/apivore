require 'apivore/rspec_matchers'
require 'action_controller'
require 'action_dispatch'
require 'hashie'

module Apivore
  module RspecBuilder
    include Apivore::RspecMatchers
    include ActionDispatch::Integration
    include RSpec::Mocks::ExampleMethods
    
    @@setups ||= {}

    def apivore_setup(path, method, response, &block)
      @@setups[path + method + response] = block
    end

    def get_apivore_setup(path, method, response)
      setup = @@setups[path + method + response]
      (instance_eval &setup if setup) || {}
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
      path
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

    def validate(swagger_path)

      describe "the swagger documentation" do
        before { get swagger_path }
        subject { body }
        it { should be_valid_swagger }
        it { should have_models_for_all_get_endpoints }
      end

      swagger = apivore_swagger(swagger_path)
      swagger.each_response do |path, method, response_code, fragment|
        describe "path #{path} method #{method} response #{response_code}" do
          it "responds with the specified models" do

            setup_data = get_apivore_setup(path, method, response_code)
            full_path = apivore_build_path(swagger.base_path + path, setup_data)

            # e.g., get(full_path)
            if setup_data.is_a?(Hash)
              send(method, full_path, setup_data['_data'] || {}, setup_data['_headers'] || {})
            else
              send(method, full_path)
            end

            expect(response).to have_http_status(response_code), "expected #{response_code} array, got #{response.status}: #{response.body}"

            if fragment
              expect(response.body).to conform_to_the_documented_model_for(swagger, fragment)
            end

          end
        end
      end

    end
  end
end
