require 'spec_helper'

describe Apivore::SwaggerChecker do
  describe '#instance_of' do
    let(:sample_file_path) { File.join(File.dirname(__FILE__), 'data', '01_sample2.0.json') }

    it 'should be able to load the file via ActionDispatch::Integration' do
      json = nil
      open(sample_file_path) { |file| json = file.read }
      response_double = double('response', body: json)
      session_double = double('integration', response: response_double, get: 200)
      allow(ActionDispatch::Integration::Session).to receive(:new).and_return(session_double)

      expect { Apivore::SwaggerChecker.instance_for("/random/url.json") }.to_not raise_error
    end

    it 'should be able to load the swagger file locally' do
      expect { Apivore::SwaggerChecker.instance_for(sample_file_path) }.to_not raise_error
    end

    it 'should throw an exception if it is unable to load the file' do
      expect { Apivore::SwaggerChecker.instance_for('not_found.json') }.to raise_error(RuntimeError)
    end
  end
end
