
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

  describe "a path exists but the API responds with a unexpected http response code" do
    it 'should show which path has the problem and what the expected and actual response code are' do
      stdout = `rspec spec/data/example_specs.rb --example 'unexpected http response'`
      expect(stdout).to match(/1 failure/)
      expect(stdout).to match(/expected 222 .*, got 200/)
    end
  end

end
