Gem::Specification.new do |s|
  s.name        = 'apivore'
  s.version     = '0.0.0'
  s.date        = '2014-11-16'
  s.summary     = "Automatically tests your API using its Swagger description of end-points, models, and query parameters."
  s.description = "Automatically tests your API using its Swagger description of end-points, models, and query parameters."
  s.authors     = ["Charles Horn"]
  s.email       = 'charles.horn@gmail.com'
  s.files       = ['lib/apivore.rb', 'lib/apivore/rspec_matchers.rb', 'data/swagger_2.0_schema.json']
  s.homepage    = 'http://github.com/hornc/apivore'
  s.add_runtime_dependency 'json-schema'

end
