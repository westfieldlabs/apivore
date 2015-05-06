require 'apivore/rspec_matchers'
require 'apivore/rspec_helpers'
require 'apivore/swagger_checker'
require 'apivore/swagger'
require 'rspec/rails'

RSpec.configure do |config|
  config.include Apivore::RspecMatchers, type: :apivore
  config.include Apivore::RspecHelpers, type: :apivore
end
