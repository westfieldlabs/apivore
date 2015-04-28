require 'spec_helper'
include Apivore::RspecBuilder

describe "Example API", type: :apivore, order: :defined do

  include Apivore::RspecHelpers

  subject { Apivore::SwaggerChecker.instance_for("/swagger-doc.json") }

  context "has valid paths" do
    it "documents /services.json" do
      expect(subject).to document(:get, "/services.json", 200)
    end

    it "documents /services.json" do
      expect(subject).to document(
        :post, "/services.json", 204, {'name' => 'hello world'}
      )
    end

    it "documents /services/{id}.json" do
      expect(subject).to document(
        :get, "/services/{id}.json", 200, {'id' => 1}
      )
    end

    it "documents /services/{id}.json" do
      expect(subject).to document(
        :put, "/services/{id}.json", 204, {'id' => 1}
      )
    end

    it "documents /services/{id}.json" do
      expect(subject).to document(
        :delete, "/services/{id}.json", 204, {'id' => 1}
      )
    end

    it "documents /services/{id}.json" do
      expect(subject).to document(
        :patch, "/services/{id}.json", 204, {'id' => 1}
      )
    end
  end

  context "and" do
    it { is_expected.to document_all_paths }
  end

end
