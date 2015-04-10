require 'spec_helper'
include Apivore::RspecBuilder

describe 'Apivore::RspecBuilder' do
  let(:dummy_class) { Class.new { include RspecBuilder } }
  subject { :dummy_class }

  it { should respond_to(:apivore_setup) } 
  it { should respond_to(:get_apivore_setup) }

  it "should merge relevant setup blocks in order of least to most specific" do
    apivore_setup do
      { 'id' => 1, 'name' => 'michel' }
    end

    apivore_setup "/thing", "get", "200" do
      { 'content' => 'test', 'name' => 'francois' }
    end

    apivore_setup "get", "200" do
      { 'id' => 2, 'name' => 'dora' }
    end

    apivore_setup "500" do
      { 'id' => 5 }
    end

    expect(get_apivore_setup("/thing", "get", "200")).to eq({'id' => 2, 'name' => 'francois', 'content' => 'test'})
    expect(get_apivore_setup("/thing", "get", "500")).to eq({'id' => 5, 'name' => 'michel'})
  end
end
