require 'apivore/rspec_matchers'
require 'action_controller'
require 'action_dispatch'

module Apivore
  module RspecBuilder
    include Apivore::RspecMatchers
    include ActionDispatch::Integration

    def test_setup(path, method, response, &block)
      @@setups ||= {}
      @@setups[path] ||= {}
      @@setups[path][method] ||= {}
      @@setups[path][method][response] = block
    end

    def validate(swagger_path)

      describe "the swagger documentation" do
        before {
          get swagger_path
        }
        subject { body }
        it { should be_valid_swagger '2.0' }
        it { should have_models_for_all_get_endpoints } # this is not required by the swagger spec, but is helpful for these tests for the momemt
      end

      describe "GET paths" do
        # Build the various path tests by reading the swagger.json and iterating through the paths BEFORE the rspec tests are run
        session = ActionDispatch::Integration::Session.new(Rails.application)
        session.get swagger_path
        swagger = Apivore::ApiDescription.new(session.response.body)

        method = 'get'
        http_response = '200'
        swagger.paths(method).each do |path|

          describe "#{path.name} #{method} response" do
            if @@setups[path.name]
              before {
                values = (@@setups[path.name][method][http_response]).call
                @full_path = path.full_path
                matchdata = @full_path.scan(/\{([^}]+)\}/)
                if matchdata
                  matchdata.each do |param|
                    if values[param.first]
                      @full_path.gsub!("{#{param.first}}", values[param.first].to_s)
                    end
                  end
                end
              }
            end

            it "responds with the specified models" do
              get @full_path || path.full_path
              expect(response).to have_http_status(:success)
              expect(response.body).to conform_to_the_documented_model_for(path)
            end
          end
        end
      end
    end
  end
end
