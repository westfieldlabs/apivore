
context "Apivore tests running against a mock API" do

  describe "the test checks unimplemented path" do
    it 'should show an alert that the specific path is unimplemented' do
      stdout = `rspec spec/data/example_specs.rb --example 'unimplemented path'`
      expect(stdout).to match(/1 failure/)
      expect(stdout).to match(/Path \/not_implemented.json did not respond with expected status code. Expected 200 got 404/)
    end
  end

  describe "a path exists but the API response contains a property of a different type" do
    it 'should show which path and field has the problem' do
      stdout = `rspec spec/data/example_specs.rb --example 'mismatched property type'`
      expect(stdout).to match(/1 failure/)
      expect(stdout).to include("'/api/services/1.json#/name' of type String did not match one or more of the following types: integer, null")
    end
  end

  describe "a path exists but the API responds with an unexpected http response code" do
    it 'should show which path has the problem and what the expected and actual response codes are' do
      stdout = `rspec spec/data/example_specs.rb --example 'unexpected http response'`
      expect(stdout).to match(/1 failure/)
      expect(stdout).to match(/Expected 222 got 200/)
    end
  end

  describe "a response containing extra (undocumented) properties where additionalProperties: false " do
    it 'should fail on undocumented properties for both index and view' do
      # This swagger doc does not document one of the properties returned by the mock API
      stdout = `rspec spec/data/example_specs.rb --example 'extra properties'`
      expect(stdout).to match(/2 failures/)
      msg = 'contains additional properties \["name"\] outside of the schema when none are allowed'
      expect(stdout).to match("'/api/services.json#/0' #{msg}") # Index
      expect(stdout).to match("'/api/services/1.json#/' #{msg}") # View
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
