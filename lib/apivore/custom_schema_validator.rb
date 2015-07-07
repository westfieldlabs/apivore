module Apivore
  class CustomSchemaValidator
    def initialize(custom_schema)
      @schema = File.expand_path("../../data/custom_schemata/#{custom_schema}", File.dirname(__FILE__))
    end

    def matches?(swagger_checker)
      @results = JSON::Validator.fully_validate(@schema, swagger_checker.swagger)
      @results.empty?
    end

    def description
      "additionally conforms to #{@schema}"
    end

    def failure_message
      @results.join("\n")
    end
  end
end
