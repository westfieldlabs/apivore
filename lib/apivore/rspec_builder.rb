require 'apivore/rspec_matchers'
require 'action_controller'
require 'action_dispatch'
require 'hashie'

module Apivore
  module RspecBuilder
    include Apivore::RspecMatchers
    include ActionDispatch::Integration

    def apivore_setup(path, method, response, &block)
      @@setups ||= {}
      @@setups[path + method + response] = block
    end

    def run_apivore_setup(path, method, response_code, base_path)
      key = path + method + response_code
      if @@setups[key]
        @@setups[key].call.each do |key, data|
          path = path.gsub "{#{key}}", data.to_s
        end
      end
      base_path + path
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

            full_path = run_apivore_setup(
              path,
              method,
              response_code,
              swagger['basePath']
            )

            send(method, full_path) # EG: get(full_path)
            expect(response).to have_http_status(response_code)

            if fragment
              expect(response.body).to conform_to_the_documented_model_for(swagger, fragment)
            end

          end
        end
      end

    end
  end
end
