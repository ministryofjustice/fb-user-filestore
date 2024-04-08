require 'rails_helper'

RSpec.describe Adapters::ServiceTokenCacheClient do
  describe 'initializing' do
    subject { described_class.new(params) }

    context 'with a :root_url param' do
      let(:params) { {root_url: 'a root url'} }

      it 'stores the root_url' do
        expect(subject.root_url).to eq('a root url')
      end
    end

    context 'with no :root_url param' do
      let(:params) { {} }
      it 'stores the environment variable SERVICE_TOKEN_CACHE_ROOT_URL as root_url' do
        allow(ENV).to receive(:[]).with('SERVICE_TOKEN_CACHE_ROOT_URL').and_return('value from env var')
        expect(subject.root_url).to eq('value from env var')
      end
    end
  end

  subject { described_class.new(root_url: 'http://www.example.com') }

  describe '#public_key_for' do
    let(:service_slug) { 'my-service' }
    let(:encoded_public_key) do
      'LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUEzU1RCMkxnaDAyWWt0K0xxejluNgo5MlNwV0xFdXNUR1hEMGlmWTBuRHpmbXF4MWVlbHoxeHhwSk9MZXRyTGdxbjM3aE1qTlkwL25BQ2NNZHVFSDlLClhycmFieFhYVGwxeVkyMStnbVd4NDlOZVlESW5iZG0rNnM1S3ZMZ1VOTjdYVmNlUDlQdXFaeXN4Q1ZBNFRubUwKRURLZ2xTV2JVeWZ0QmVhVENKVkk2NFoxMmRNdFBiQWd4V0FmZVNMbGI3QlBsc0htL0gwQUFMK25iYU9Da3d2cgpQSkRMVFZPek9XSE1vR2dzMnJ4akJIRC9OV05ac1RWUWFvNFh3aGVidWRobHZNaWtFVzMyV0tnS3VISFc4emR2ClU4TWozM1RYK1picVhPaWtkRE54dHd2a1hGN0xBM1loOExJNUd5ZDlwNmYyN01mbGRnVUlIU3hjSnB5MUo4QVAKcXdJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg=='
    end
    let(:mock_response) do
      double('response', body: {token: encoded_public_key}.to_json, code: 200)
    end

    let(:expected_headers) do
      {
        'User-Agent' => 'UserFilestore',
        'X-Request-Id' => '12345',
      }
    end

    before do
      allow(Current).to receive(:request_id).and_return('12345')
    end

    it 'returns public key' do
      expect(
        Net::HTTP
      ).to receive(:get_response).with(
        URI('http://www.example.com/service/v2/my-service'), expected_headers
      ).and_return(mock_response)

      subject.public_key_for(service_slug)
    end
  end
end
