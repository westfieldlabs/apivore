require 'apivore/rspec_matchers'
module Apivore
  module RspecBuilder
    include Apivore::RspecMatchers
    def test_setup(path, method, response, &block)
      puts "DEBUG: adding test config for: #{path}, #{method}, #{response}"
      @substitutions ||= {}
      @substitutions[path] ||= {}
      @substitutions[path][method] ||= {}
      @substitutions[path][method][response] = block
    end

    def validate(swagger_path)

      before {
        get swagger_path
      }

      describe "the swagger documentation" do
        subject { body }
        it { should be_valid_swagger '2.0' }
        it { should have_models_for_all_get_endpoints } # this is not required by the swagger spec, but is helpful for these tests for the momemt
      end

      describe "GET paths" do
        it "respond with the specified models" do
          swagger = Apivore::ApiDescription.new(response.body)
          #failures = swagger.paths('get').reject do |path|
          swagger.paths('get').each do |path|
            get(path.full_path)
            expect(response).to have_http_status :success
            #expect(path).to describe(response)
            expect(response.body).to conform_to_the_documented_model_for(path)
          end
        end
      end
    end
  end
end
