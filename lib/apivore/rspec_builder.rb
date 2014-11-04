require 'apivore/rspec_matchers'

module Apivore
  module RspecBuilder
    include Apivore::RspecMatchers
    include ActionDispatch::Integration

    def test_setup(path, method, response, &block)
      puts "DEBUG: adding test config for: #{path}, #{method}, #{response}"
      @@substitutions ||= {}
      @@substitutions[path] ||= {}
      @@substitutions[path][method] ||= {}
      @@substitutions[path][method][response] = block
    end

    def validate(swagger_path)

      before {
        get swagger_path
      }

      describe "the swagger documentation" do
        subject { body }
        #it { should be_valid_swagger '2.0' }
        it { should have_models_for_all_get_endpoints } # this is not required by the swagger spec, but is helpful for these tests for the momemt
      end

      # Build the various path tests by reading the swagger.json and iterating through the paths BEFORE the rspec tests are run
      describe "GET paths" do

        before {
          swagger = Apivore::ApiDescription.new(response.body)
          @@substitutions.each do |k, s|
            values = s['get']['200'].call
            puts "DEBUG BEFORE: #{k}: #{values}"
            swagger.append_substitution(k, values[0], values[1])
          end
        }

        session = ActionDispatch::Integration::Session.new(Rails.application)
        session.get swagger_path
        swagger = Apivore::ApiDescription.new(session.response.body)

        method = 'get'
        swagger.paths(method).each do |path|
          describe "#{path.name} #{method} response" do
            it "responds with the specified models" do
              get path.full_path
              expect(response).to have_http_status(:success)
              expect(response.body).to conform_to_the_documented_model_for(path)
            end
          end
        end
      end
    end
  end
end
