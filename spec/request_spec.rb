require 'spec_helper'
include Apivore::RspecBuilder

describe "Example API", :type => :request do

  validate_against("/swagger-doc.json")

  apivore_setup '/services.json', 'get', '200' do
    expect(Rails.application).to receive(:call).and_call_original
  end

  apivore_setup '/services.json', 'post', '204' do
    {"_data" => {'name' => 'hello world'}}
  end

  apivore_setup '/services/{id}.json', 'get', '200' do
    {'id' => 1}
  end

  apivore_setup '/services/{id}.json', 'put', '204' do
    {'id' => 1}
  end

  apivore_setup '/services/{id}.json', 'delete', '204' do
    {'id' => 1}
  end

  apivore_setup '/services/{id}.json', 'patch', '204' do
    {'id' => 1}
  end
end
