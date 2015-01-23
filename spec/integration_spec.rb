
context "Apivore tests running against a mock API" do
  describe "valid swagger and correctly implemented API" do
    it 'passes when the swagger description does match the implemented API' do
      stdout = `rspec spec/data/example_specs.rb --example 'passing doc'`
      expect(stdout).to match(/0 failures/)
    end
  end

  describe "the swagger documents an unimplemented path" do
    it 'should show and alert that the specific path is unimplemented' do
      stdout = `rspec spec/data/example_specs.rb --example 'unimplemented path in doc'`
      expect(stdout).to match(/1 failure/)
      expect(stdout).to match(/1\) API testing scenarios unimplemented path in doc path \/not_implemented.json method get response 200 responds with the specified models/)
    end
  end

  describe "a path exists but the API response contains a property of a different type" do
    it 'should show which path and field has the problem' do
      stdout = `rspec spec/data/example_specs.rb --example 'mismatched property type'`
      expect(stdout).to match(/2 failures/)
      expect(stdout).to match("'#/name' of type String did not match one or more of the following types: integer, null")
    end
  end

  describe "a path exists but the API responds with an unexpected http response code" do
    it 'should show which path has the problem and what the expected and actual response codes are' do
      stdout = `rspec spec/data/example_specs.rb --example 'unexpected http response'`
      expect(stdout).to match(/1 failure/)
      expect(stdout).to match(/expected 222 .*, got 200/)
    end
  end

  describe "a response contains extra (undocumented) properties (Default Non-strict validation)" do
    it 'should not throw any errors' do
      # This swagger doc does not document one one of the properties the mock API returns
      stdout = `rspec spec/data/example_specs.rb --example 'extra properties'`
      expect(stdout).to match(/0 failures/)
    end
  end

  describe "a response contains extra (undocumented) properties (configured with strict validation)" do
    it 'should error on undocumented fields' do
      # This swagger doc does not document one one of the properties the mock API returns
      # TODO: set configuration to validate :strict => true so the strictness behaviour is configurable
      pending("needs configurable option to allow :strict => true validation")
      stdout = `rspec spec/data/example_specs.rb --example 'extra properties'`
      expect(stdout).to match(/2 failures/)
      expect(stdout).to match("'#/0' contained undefined properties: 'name'") # Index error
      expect(stdout).to match("'#/' contained undefined properties: 'name'") # View error
    end
  end

  describe "a response is missing a required property" do

  end

  describe "a reponse is missing a non-required property" do

  end
end
