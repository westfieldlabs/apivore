module Apivore
  module RspecMatchers
    extend RSpec::Matchers::DSL
    matcher :be_valid_swagger do |version|
      match do |body|
        @d = ApiDescription.new(body)
        @d.swagger_version == version
      end

      failure_message do |body|
        "expected Swagger version #{version}, got #{@d.swagger_version}."
      end
    end

    matcher :have_models do
      match do |body|
        @d = ApiDescription.new(body)
        pass = true
        @d.paths.each do |path|
          pass &= @d.has_model_for?(path)
        end
      pass
      end
    end
  end
end
