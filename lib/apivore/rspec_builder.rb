require 'apivore/rspec_matchers'
require 'action_controller'
require 'action_dispatch'
require 'hashie'

module Apivore
  module RspecBuilder
    include Apivore::RspecMatchers
    include ActionDispatch::Integration

    @@setups ||= {}

    def apivore_setup(path, method, response, &block)
      @@setups[path + method + response] = block
    end

    def get_apivore_setup(path, method, response)
      @@setups[path + method + response].try(:call) || {}
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
      session.get swagger_path
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
            if setup_data.is_a?(Hash) && setup_data['_data']
              send(method, full_path, setup_data['_data'])
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
