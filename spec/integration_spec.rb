
context "Apivore tests running against a mock API" do
  describe "valid swagger and correctly implemented API" do
    it 'passes when the swagger description does match the implemented API' do
      stdout = `rspec spec/data/example_specs.rb --example 'passing doc'`
      expect(stdout).to match(/0 failures/)
    end
  end

  describe "the swagger documents an unimplemented path" do
    it 'should show an alert that the specific path is unimplemented' do
      stdout = `rspec spec/data/example_specs.rb --example 'unimplemented path in doc'`
      expect(stdout).to match(/1 failure/)
      expect(stdout).to match(/expected 200 array, got 404/)
    end
  end

  describe "a path exists but the API response contains a property of a different type" do
    it 'should show which path and field has the problem for both index and view' do
      stdout = `rspec spec/data/example_specs.rb --example 'mismatched property type'`
      expect(stdout).to match(/2 failures/)
      expect(stdout).to match("'/api/services/1.json#/name' of type String did not match one or more of the following types: integer, null")
    end
  end

  describe "a path exists but the API responds with an unexpected http response code" do
    it 'should show which path has the problem and what the expected and actual response codes are' do
      stdout = `rspec spec/data/example_specs.rb --example 'unexpected http response'`
      expect(stdout).to match(/1 failure/)
      expect(stdout).to match(/expected 222 .*, got 200/)
    end
  end

  describe "a response containing extra (undocumented) properties (configured with non-strict validation)" do
    it 'should pass validation' do
      pending "needs configurable option to allow :strict => false validation"
      # TODO: set configuration to validate :strict => true so the strictness behaviour is configurable
      # This swagger doc does not document one of the properties returned by the mock API
      stdout = `rspec spec/data/example_specs.rb --example 'extra properties'`
      expect(stdout).to match(/0 failures/)
    end
  end

  describe "a response containing extra (undocumented) properties (default strict validation)" do
    it 'should fail on undocumented properties for both index and view' do
      # This swagger doc does not document one of the properties returned by the mock API
      stdout = `rspec spec/data/example_specs.rb --example 'extra properties'`
      expect(stdout).to match(/2 failures/)
      expect(stdout).to match("'/api/services.json#/0' contained undefined properties: 'name'") # Index
      expect(stdout).to match("'/api/services/1.json#/' contained undefined properties: 'name'")  # View
    end
  end

  describe "a response missing a required property" do
    it 'should fail on the missing property for both index and view' do
      stdout = `rspec spec/data/example_specs.rb --example 'missing required'`
      expect(stdout).to match(/2 failures/)
      expect(stdout).to match("'/api/services.json#/0' did not contain a required property of 'test_required'") # Index
      expect(stdout).to match("'/api/services/1.json#/' did not contain a required property of 'test_required'")  # View
    end
  end

  describe "a reponse is missing an optional property" do
    it 'should pass validation' do
      stdout = `rspec spec/data/example_specs.rb --example 'missing non-required'`
      expect(stdout).to match(/0 failures/)
    end
  end
end
