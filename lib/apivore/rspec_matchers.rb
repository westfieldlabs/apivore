require 'rspec/expectations'
require 'net/http'

module Apivore
  module RspecMatchers
    extend RSpec::Matchers::DSL
    matcher :be_consistent_with_swagger_definitions do |master_swagger_url, current_service|

      attr_reader :actual, :expected

      define_method :cleaned_definitions do |definitions, current_service|
        definitions.each do |key, definition_fields|
          # We ignore definitions that are owned exclusively by the current_service
          if [current_service] == definition_fields['x-services']
            definitions[key] = nil
          else
            # 'x-services' is added by api.westfield.io when aggregating swagger docs
            # Individual services will not have a 'x-services' property so we need to remove it to allow the comparison to pass
            definitions[key] = definition_fields.except 'x-services'
          end
        end.select{ |_, value| !value.nil? }
      end

      define_method :fetch_master_swagger do
        res =
          if master_swagger_url.starts_with? 'http'
            Net::HTTP.get_response(URI(master_swagger_url))
          else
            Net::HTTP.get_response(master_swagger_url, "/swagger.json")
          end

        unless res.is_a? Net::HTTPSuccess
          message = "Master swagger at #{master_swagger_url} not accessible\n"
          fail (message + res.body)
        end
        JSON.parse(res.body)
      end

      define_method :master_swagger do
        @master_swagger ||= fetch_master_swagger
      end

      match do |swagger_checker|
        our_swagger = swagger_checker.swagger
        master_definitions = cleaned_definitions(master_swagger["definitions"], current_service)
        our_definitions = our_swagger["definitions"]
        @actual = our_definitions.slice(*master_definitions.keys)
        @expected = master_definitions.slice(*our_definitions.keys)
        @actual == @expected
      end

      diffable
    end
  end
end
