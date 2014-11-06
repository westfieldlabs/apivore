require 'spec_helper'

describe 'Apivore::ApiDescription' do

  let(:doc) { IO.read(File.join(File.dirname(__FILE__), "../data", "sample2.0.json")) }
  let(:swagger) { Apivore::Swagger.new(JSON.parse(doc)) }

  subject { swagger }
  it { should be_an_instance_of(Apivore::Swagger) }
  it { should respond_to(:version) }
  it { should respond_to(:validate) }

  describe 'swagger version' do
    subject { swagger.version }
    it { should == '2.0' }
  end

  describe 'validates against Swagger 2.0' do
    subject { swagger.validate }
    it { should == [] }
  end
end
