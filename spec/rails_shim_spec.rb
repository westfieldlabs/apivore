require 'spec_helper'

describe 'Apivore::RailsShim' do

  describe '.action_dispatch_request_args' do
    subject {
      Apivore::RailsShim.action_dispatch_request_args(
        path,
        params: params,
        headers: headers
      )
    }
    let(:path) { '/posts' }
    let(:params) { { 'foo' => 'bar' } }
    let(:headers) { { 'X-Foo' => 'baz' } }

    before do
      stub_const('ActionPack::VERSION::MAJOR', actionpack_major_version)
    end

    context 'using Rails 4' do
      let(:actionpack_major_version) { 4 }

      it 'returns path, params and headers as positional arguments' do
        expect(subject).to eq([path, params, headers])
      end
    end

    context 'using Rails 5' do
      let(:actionpack_major_version) { 5 }

      it 'returns path as a positional argument and params and headers as keyword arguments' do
        expect(subject).to eq([path, { params: params, headers: headers }])
      end
    end
  end
end
