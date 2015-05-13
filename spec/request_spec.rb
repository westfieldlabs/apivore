require 'spec_helper'

describe "Example API", type: :apivore, order: :defined do
  subject { Apivore::SwaggerChecker.instance_for("/swagger-doc.json") }

  context "has valid paths" do
    it 'allows the same path (with response documented) to be tested twice' do
      expect(subject).to validate(:get, "/services.json", 200)
      expect(subject).to validate(:get, "/services.json", 200)
    end

    it do
      expect(subject).to validate(
        :post, "/services.json", 204, {'name' => 'hello world'}
      )
    end

    it do
      expect(subject).to validate(
        :get, "/services/{id}.json", 200, {'id' => 1}
      )
    end

    it do
      expect(subject).to validate(
        :put, "/services/{id}.json", 204, {'id' => 1}
      )
    end

    it do
      expect(subject).to validate(
        :delete, "/services/{id}.json", 204, {'id' => 1}
      )
    end

    it do
      expect(subject).to validate(
        :patch, "/services/{id}.json", 204, {'id' => 1}
      )
    end
  end

  context 'and' do
    it 'tests all documented routes' do
      expect(subject).to validate_all_paths
    end
    # it 'has definitions consistent with the master docs' do
    #   expect(subject).to be_consistent_with_swagger_definitions(
    #     "api.westfield.io", 'deal'
    #   )
    # end
  end

end
