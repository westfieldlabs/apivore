require 'action_controller'
require 'action_dispatch'

module Apivore
  class Validator
    include ::ActionDispatch::Integration::Runner

    attr_reader :method, :path, :expected_response_code, :params

    def initialize(method, path, expected_response_code, params = {})
      @method = method.to_s
      @path = path.to_s
      @params = params
      @expected_response_code = expected_response_code.to_i
    end

    def matches?(swagger_checker)
      pre_checks(swagger_checker)

      unless has_errors?
        send(
          method,
          full_path(swagger_checker),
          params['_data'] || {},
          params['_headers'] || {}
        )
        swagger_checker.response = response
        post_checks(swagger_checker)

        if has_errors? && response.body.length > 0
          puts "XXXXXXXXXXXXXXXX"
          puts "Response body for '#{method} #{full_path(swagger_checker)}'\n"
          puts JSON.pretty_generate(JSON.parse(response.body))
          puts "XXXXXXXXXXXXXXXX"
        end

        swagger_checker.remove_tested_end_point_response(
          path, method, expected_response_code
        )
      end

      !has_errors?
    end

    def full_path(swagger_checker)
      apivore_build_path(swagger_checker.base_path + path, params)
    end

    def apivore_build_path(path, data)
      path.scan(/\{([^\}]*)\}/).each do |param|
        key = param.first
        if data && data[key]
          path = path.gsub "{#{key}}", data[key].to_s
        else
          raise URI::InvalidURIError, "No substitution data found for {#{key}}"\
            " to test the path #{path}.", caller
        end
      end
      path + (data['_query_string'] ? "?#{data['_query_string']}" : '')
    end


    def pre_checks(swagger_checker)
      check_request_path(swagger_checker)
    end

    def post_checks(swagger_checker)
      check_status_code
      check_response_is_valid(swagger_checker) unless has_errors?
    end

    def check_request_path(swagger_checker)
      if !swagger_checker.has_path?(path)
        errors << "Swagger doc: #{swagger_checker.swagger_path} does not have"\
          " a documented path for #{path}"
      elsif !swagger_checker.has_method_at_path?(path, method)
        errors << "Swagger doc: #{swagger_checker.swagger_path} does not have"\
          " a documented path for #{method} #{path}"
      elsif !swagger_checker.has_response_code_for_path?(path, method, expected_response_code)
        errors << "Swagger doc: #{swagger_checker.swagger_path} does not have"\
          " a documented response code of #{expected_response_code} at path"\
          " #{method} #{path}. "\
          "\n             Available response codes: #{swagger_checker.response_codes_for_path(path, method)}"
      elsif method == "get" && swagger_checker.fragment(path, method, expected_response_code).nil?
        errors << "Swagger doc: #{swagger_checker.swagger_path} missing"\
          " response model for get request with #{path} for code"\
          " #{expected_response_code}"
      end
    end

    def check_status_code
      if response.status != expected_response_code
        errors << "Path #{path} did not respond with expected status code."\
          " Expected #{expected_response_code} got #{response.status}"\
          "\nResponse body: #{response.body}"
      end
    end

    def check_response_is_valid(swagger_checker)
      swagger_errors = swagger_checker.has_matching_document_for(
        path, method, response.status, response_body
      )
      unless swagger_errors.empty?
        errors.concat(
          swagger_errors.map do |e|
            e.sub("'#", "'#{full_path(swagger_checker)}#").gsub(
              /^The property|in schema.*$/,''
            )
          end
        )
      end
    end

    def response_body
      JSON.parse(response.body) unless response.body.blank?
    end

    def has_errors?
      !errors.empty?
    end

    def failure_message
      errors.join(" ")
    end

    def errors
      @errors ||= []
    end

    def description
      "validate that #{method} #{path} returns #{expected_response_code}"
    end

    # Required by ActionDispatch::Integration::Runner
    def app
      ::Rails.application
    end

    # Required by rails
    def reset_template_assertion
    end
  end
end
