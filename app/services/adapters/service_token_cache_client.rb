require 'net/http'

module Adapters
  class ServiceTokenCacheClient
    attr_accessor :root_url

    def initialize(params={})
      @root_url = params[:root_url] || ENV['SERVICE_TOKEN_CACHE_ROOT_URL']
    end

    def public_key_for(service_slug)
      url = public_key_uri(service_slug)
      response = Net::HTTP.get_response(url, headers)

      return unless response.code.to_i == 200

      public_key_string = Base64.strict_decode64(JSON.parse(response.body).fetch('token'))
      OpenSSL::PKey::RSA.new(public_key_string)
    end

    private

    def headers
      {
        'User-Agent' => 'UserFilestore',
        'X-Request-Id' => Current.request_id
      }.freeze
    end

    def public_key_uri(service_slug)
      URI.join(root_url, '/service/v2/', service_slug)
    end
  end
end
