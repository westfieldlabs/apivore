module Apivore
  module RspecMatchers
    extend RSpec::Matchers::DSL
    matcher :be_valid_swagger do |version|
      match do |body|
        @d = ApiDescription.new(body)
        @results = @d.validate(version)
        (@d.swagger_version == version) && (@results == [])
      end

      failure_message do |body|
        if version != @d.swagger_version
          "expected Swagger version #{version}, got #{@d.swagger_version}."
        else
          msg = "The document fails to validate as Swagger #{version}:\n"
          @results.each { |r| msg += "  #{r}\n" }
          msg
        end
      end
    end

    matcher :have_models_for_all_get_endpoints do
      match do |body|
        @d = ApiDescription.new(body)
        pass = true
        @d.paths('get').each do |path|
          @current_path = path
          pass &= path.has_model?('get', '200')
          return pass if !pass # return now if the last check failed
        end
      pass
      end

      failure_message do |body|
        "Unable to find a valid model for #{@current_path.name} get 200 response."
      end
    end
  end
end
