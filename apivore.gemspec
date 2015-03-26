$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'apivore'
  s.version     = '0.0.1'
  s.date        = '2014-11-16'
  s.summary     = "Automatically tests your API using its Swagger description of end-points, models, and query parameters."
  s.description = "Automatically tests your API using its Swagger description of end-points, models, and query parameters."
  s.authors     = ["Charles Horn"]
  s.email       = 'charles.horn@gmail.com'
  s.files       = ['lib/apivore.rb', 'lib/apivore/rspec_matchers.rb', 'lib/apivore/rspec_builder.rb', 'data/swagger_2.0_schema.json']
  s.homepage    = 'http://github.com/hornc/apivore'
  s.add_runtime_dependency 'json-schema', '~> 2.5.1'
  s.add_runtime_dependency 'rspec-expectations', '~> 3.1'
  s.add_runtime_dependency 'rspec-mocks', '~> 3.1'
  s.add_runtime_dependency 'actionpack', '~> 4'
  s.add_runtime_dependency 'hashie', '>= 3.3.1'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'activesupport'

  if RUBY_VERSION >= '2.2.0'
    s.add_development_dependency 'test-unit'
  end
end
