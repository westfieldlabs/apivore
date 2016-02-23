$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'apivore'
  s.version     = '1.5.0'
  s.date        = '2016-02-24'
  s.summary     = "Tests your API against its OpenAPI (Swagger) 2.0 spec"
  s.description = "Tests your rails API using its OpenAPI (Swagger) description of end-points, models, and query parameters."
  s.authors     = ["Charles Horn"]
  s.email       = 'charles.horn@gmail.com'
  s.files       = ['lib/apivore.rb', 'data/swagger_2.0_schema.json', 'data/draft04_schema.json']
  s.files      += Dir['lib/apivore/*.rb']
  s.files      += Dir['data/custom_schemata/*.json']
  s.homepage    = 'http://github.com/westfieldlabs/apivore'
  s.licenses    = ['Apache 2.0']

  s.add_runtime_dependency 'json-schema', '~> 2.5'
  s.add_runtime_dependency 'rspec', '~> 3'
  s.add_runtime_dependency 'rspec-expectations', '~> 3.1'
  s.add_runtime_dependency 'rspec-mocks', '~> 3.1'
  s.add_runtime_dependency 'actionpack', '~> 4'
  s.add_runtime_dependency 'hashie', '~> 3.3'
  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'rake', '~> 10.3'
  s.add_development_dependency 'rspec-rails', '~> 3'
  s.add_development_dependency 'activesupport', '~> 4'

  if RUBY_VERSION >= '2.2.0'
    s.add_development_dependency 'test-unit', '~> 3'
  end
end
