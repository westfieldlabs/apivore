require 'json-schema'
require 'rspec/expectations'
require 'net/http'

module Apivore
  module RspecMatchers
    extend RSpec::Matchers::DSL
    matcher :be_consistent_with_swagger_definitions do |master_swagger_host, current_service|

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
        req = Net::HTTP.get(master_swagger_host, "/swagger.json")
        JSON.parse(req)
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
