require 'rails_helper'

RSpec.describe 'POST /presigned-s3-url', type: :request do
  let(:service_slug) { 'my-service' }
  let(:user_identifier) { SecureRandom::uuid }
  let(:fingerprint_with_prefix) do
    '28d-aaa59621acecd4b1596dd0e96968c6cec3fae7927613a12c357e7a62e1187aaa'
  end
  let(:headers) do
    { 'content-type' => 'application/json' }
  end
  let(:url) do
    "/service/#{service_slug}/user/#{user_identifier}/#{fingerprint_with_prefix}/presigned-s3-url"
  end

  it 'responds with a 201 created' do
    post url, params: {}.to_json, headers: headers
    expect(response.status).to eq(201)
  end
end
