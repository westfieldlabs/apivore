require 'spec_helper'

describe 'Apivore::ApiDescription' do

  let(:doc) { IO.read(File.join(File.dirname(__FILE__), "../data", "sample2.0.json")) }

  before do
    @api_description = Apivore::ApiDescription.new(doc)
  end

  subject { @api_description }
  it { should be_an_instance_of(Apivore::ApiDescription) }
  it { should respond_to(:swagger_version) }
  it { should respond_to(:validate).with(1).argument }
  it { should respond_to(:valid).with(1).argument }
  it { should respond_to(:paths) }

  describe 'swagger version' do
    subject { @api_description.swagger_version }
    it { should == '2.0' }
  end

  describe 'validates against Swagger 2.0' do
    subject { @api_description.validate('2.0') }
    it { should == [] }
  end
end
