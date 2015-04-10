require 'spec_helper'
include Apivore::RspecBuilder

describe "Example API", :type => :request, order: :defined do

  validate_against("/swagger-doc.json")

  swagger_description('/services.json', 'get', '200') { is_expected.to be_correct }
  swagger_description(
    '/services.json', 'post', '204', {"_data" => {'name' => 'hello world'}}
  ) { is_expected.to be_correct }

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
  ensure_paths_are_tested
end
