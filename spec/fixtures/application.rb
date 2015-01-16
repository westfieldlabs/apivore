require 'active_support/all'
require 'action_controller'
require 'action_dispatch'
require 'rails'

# Boilerplate
module Rails
  class App
    def env_config; {} end
    def routes
      return @routes if defined?(@routes)
      @routes = ActionDispatch::Routing::RouteSet.new
      @routes.draw do
        get '/swagger-doc.json' => "apivores#swagger_doc"

      end
      @routes
    end

    def call(env)
      path = env['PATH_INFO']
      method = env['REQUEST_METHOD']
      case "#{method} #{path}"
      when "GET /swagger-doc.json"
        respond_with 200, File.read(File.expand_path("../../data/sample2.0.json", __FILE__))
      when "GET /02_unimplemented_path.json"
        respond_with 200, File.read(File.expand_path("../../data/02_unimplemented_path.json", __FILE__))
      when "GET /03_mismatched_response.json"
        respond_with 200, File.read(File.expand_path("../../data/03_mismatched_response.json", __FILE__))
      when "GET /api/services.json"
        respond_with 200, [{ id: 1, name: "hello world" }].to_json
      when "POST /api/services.json"
        respond_with 204
      when "GET /api/services/1.json"
        respond_with 200, { id: 1, name: "hello world" }.to_json
      when "PUT /api/services/1.json"
        respond_with 204
      when "DELETE /api/services/1.json"
        respond_with 204
      when "PATCH /api/services/1.json"
        respond_with 204
      end
    end

    def respond_with(status_code, data = "")
      [status_code, {}, data]
    end

  end
  def self.application
    @app ||= App.new
  end
end
