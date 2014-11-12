require 'spec_helper'
include Apivore::RspecBuilder

#describe "Apivores" do
describe ApivoresController, :type => :request do

  # validate("/swagger-doc.json")

  it "uses the block to determine the value" do
    get '/swagger-doc.json'
  end

end