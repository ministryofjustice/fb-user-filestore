require 'rails_helper'

RSpec.describe 'POST /service/:service_slug/user/:user_identifier/public-file', type: :request do
  let(:service_slug) { 'my-service' }
  let(:user_identifier) { SecureRandom::uuid }
  let(:headers) do
    {
      'content-type' => 'application/json',
      'X-Encrypted-User-Id-And-Token' => '12345678901234567890123456789012'
    }
  end
  let(:url) { "/service/#{service_slug}/user/#{user_identifier}/public-file" }
  let(:body) { { url: 'http://fb-user-filestore-api-svc-test-dev.formbuilder-platform-test-dev/service/ioj/user/a239313d-4d2d-4a16-b5ef-69d6e8e53e86/28d-aaa59621acecd4b1596dd0e96968c6cec3fae7927613a12c357e7a62e1187aaa' } }
  let(:s3) { Aws::S3::Client.new(stub_responses: true) }

  before do
    allow_any_instance_of(Adapters::ServiceTokenCacheClient).to receive(:get)
      .and_return('ServiceToken')
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
    s3.stub_responses(:get_object, { body: file_fixture('encrypted_file').read })
    s3.stub_responses(:put_object, {})
  end

  it 'responds with a 201 created' do
    post url, params: body.to_json, headers: headers
    expect(response.status).to eq(201)
  end

  it 'downloads the file from S3' do
    expect(s3).to receive(:get_object).once
    post url, params: body.to_json, headers: headers
  end

  it 'returns an encryption init vector and key' do
    post url, params: body.to_json, headers: headers
    expect(JSON.parse(response.body).keys).to eq(["encryption_key", "encryption_iv"])
  end

  it 'uploads a re-encrypted file to S3' do
    expect(s3).to receive(:put_object)
    post url, params: body.to_json, headers: headers
  end

  context 'without the correct payload' do
    it 'responds with error message' do
      post url, params: {}.to_json, headers: headers
      expect(response.status).to eq(400)
    end
  end
end
