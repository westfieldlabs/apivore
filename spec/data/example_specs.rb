require 'spec_helper'

context "API testing scenarios" do
  include Apivore::RspecMatchers
  include Apivore::RspecHelpers

  describe "undocumented path in test", :type => :request do
    subject { Apivore::SwaggerChecker.instance_for("/02_unimplemented_path.json") }
    it "fails" do
      expect(subject).to validate(:get, "/path_does_not_exist", 200)
    end
  end

  describe "mismatched property type", :type => :request do
    subject { Apivore::SwaggerChecker.instance_for("/03_mismatched_type_response.json") }
    it "fails" do
      expect(subject).to validate(:get, "/services/{id}.json", 200, { "id" => 1 })
    end
  end

  describe "unexpected http response", :type => :request do
    subject { Apivore::SwaggerChecker.instance_for("/04_unexpected_http_response.json") }

    it "fails" do
      expect(subject).to validate(:get, "/services.json", 222)
    end
  end

  describe "extra properties", :type => :request do
    subject { Apivore::SwaggerChecker.instance_for("/05_extra_properties.json") }

    it "fails" do
      expect(subject).to validate(:get, "/services.json", 200)
    end

    it "also fails" do
      expect(subject).to validate(:get, "/services/{id}.json", 200, { "id" => 1})
    end
  end

  describe "missing required", :type => :request do
    subject { Apivore::SwaggerChecker.instance_for("/06_missing_required_property.json") }

    it "fails" do
      expect(subject).to validate(:get, "/services.json", 200)
    end

    it "also fails" do
      expect(subject).to validate(:get, "/services/{id}.json", 200, { "id" => 1})
    end
  end

  describe "missing non-required", :type => :request do
    subject { Apivore::SwaggerChecker.instance_for("/07_missing_non-required_property.json") }

    it "fails" do
      expect(subject).to validate(:get, "/services.json", 200)
    end

    it "also fails" do
      expect(subject).to validate(:get, "/services/{id}.json", 200, { "id" => 1})
    end
  end
end
