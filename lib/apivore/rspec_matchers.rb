require 'json-schema'

module Apivore
  module RspecMatchers
    extend RSpec::Matchers::DSL
    matcher :be_valid_swagger do |version|
      match do |body|
        @api_description = ApiDescription.new(JSON.parse(body))
        @api_description.validate == []
      end

      failure_message do |body|
        msg = "The document fails to validate as Swagger #{@api_description.version}:\n\n"
        msg += @api_description.validate.join "\n\n"
        msg
      end
    end

    matcher :have_models_for_all_get_endpoints do
      match do |body|
        @d = ApiDescription.new(JSON.parse(body))
        pass = true
        @d.paths('get').each do |path|
          @current_path = path
          pass &= path.schema('get', '200') && path.schema('get', '200').model.first
          return pass if !pass # return now if the last check failed
        end
      pass
      end

      failure_message do |body|
        "Unable to find a valid model for #{@current_path.name} get 200 response."
      end
    end

    matcher :conform_to_the_documented_model_for do |schema|
      match do |body|
        body = JSON.parse(body)
        if schema.array?
          item = body.first
        else
          item = body
        end

        @results = JSON::Validator.fully_validate(schema, item)
        @results == []
      end

      failure_message do |body|
        msg = "The response for #{path.name} fails to validate against the documented schema:\n"
        @results.each { |r| msg += "  #{r}\n" }
        msg
      end
    end
  end
end
