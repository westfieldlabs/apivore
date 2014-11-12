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
  end
  def self.application
    @app ||= App.new
  end
end