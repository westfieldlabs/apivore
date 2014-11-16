require 'spec_helper'

describe 'Apivore::ApiDescription' do

  let(:doc) { IO.read(File.join(File.dirname(__FILE__), "data", "sample2.0.json")) }
  let(:swagger) { Apivore::Swagger.new(JSON.parse(doc)) }

  subject { swagger }
  it { should be_an_instance_of(Apivore::Swagger) }
  it { should respond_to(:version) }
  it { should respond_to(:validate) }
  it { should respond_to(:each_response) }
  it { should respond_to(:base_path) }

  describe 'swagger version' do
    subject { swagger.version }
    it { should == '2.0' }
  end

  describe 'validates Swagger 2.0' do
    subject { swagger.validate }
    it { should == [] }
  end

  describe 'each_response' do
    it "should return the responses" do
      expect { |b| swagger.each_response(&b) }.to yield_successive_args(
        ["/services.json", "get", "200", ['#', 'paths', '/services.json', 'get', 'responses', '200', 'schema']],
        ["/services.json", "post", "204", nil],
        ["/services/{id}.json", "get", "200", ['#', 'paths', '/services/{id}.json', 'get', 'responses', '200', 'schema']],
        ["/services/{id}.json", "put", "204", nil],
        ["/services/{id}.json", "delete", "204", nil],
        ["/services/{id}.json", "patch", "204", nil]
      )
    end
  end

end
