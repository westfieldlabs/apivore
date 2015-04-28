require 'spec_helper'
include Apivore::RspecBuilder

describe "Example API", type: :apivore, order: :defined do
  include Apivore::RspecHelpers
  subject { Apivore::SwaggerChecker.instance_for("/swagger-doc.json") }
  context "has valid paths" do
    it "documents /services.json" do
      expect(subject).to document(:get, "/services", 200)
    end
    # swagger_description('/services.json', 'get', '400') { is_expected.to be_correct }
    # swagger_description(
    #   '/services.json', 'post', '204', {"_data" => {'name' => 'hello world'}}
    # ) { is_expected.to be_correct }
  end

  context "tests everything which is documented" do
    it { is_expected.to document_all_paths }
  end
  # validate_against()



  # apivore_setup '/services.json', 'post', '204' do
  #   {"_data" => {'name' => 'hello world'}}
  # end
  #
  # apivore_setup '/services/{id}.json', 'get', '200' do
  #   {'id' => 1}
  # end
  #
  # apivore_setup '/services/{id}.json', 'put', '204' do
  #   {'id' => 1}
  # end
  #
  # apivore_setup '/services/{id}.json', 'delete', '204' do
  #   {'id' => 1}
  # end
  #
  # apivore_setup '/services/{id}.json', 'patch', '204' do
  #   {'id' => 1}
  # end
  # ensure_paths_are_tested
end
