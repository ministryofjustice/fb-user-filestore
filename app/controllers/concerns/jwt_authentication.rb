module Concerns
  module JWTAuthentication
    extend ActiveSupport::Concern

    class SubjectMismatchError < StandardError; end

    included do
      before_action :verify_token!

      if ancestors.include?(Concerns::ErrorHandling)
        rescue_from Exceptions::TokenNotPresentError do |e|
          render_json_error :unauthorized, :token_not_present
        end
        rescue_from Exceptions::TokenNotValidError do |e|
          render_json_error :forbidden, :token_not_valid
        end
      end
    end

    private

    def verify_token!
      unless access_token
        raise Exceptions::TokenNotPresentError
      end

      verify
    end

    def verify
      hmac_secret = public_key(params[:service_slug])
      @jwt_payload, _header = JWT.decode(
        access_token,
        hmac_secret,
        true,
        {
          exp_leeway: leeway,
          algorithm: 'RS256'
        }
      )

      # NOTE: verify_iat used to be in the JWT gem, but was removed in v2.2
      # so we have to do it manually
      iat_skew = @jwt_payload['iat'].to_i - Time.current.to_i

      if iat_skew.abs > leeway
        Rails.logger.warn("iat skew is #{iat_skew}, max is #{leeway} - INVALID")
        raise Exceptions::TokenNotValidError
      end

      Rails.logger.debug "token is valid"
    rescue StandardError => e
      Rails.logger.warn("Couldn't parse that token - error #{e}")
      raise Exceptions::TokenNotValidError
    end

    def public_key(service_slug)
      service = ServiceTokenService.new(service_slug: service_slug)
      service.public_key
    end

    def leeway
      @leeway ||= begin
        if request.headers['x-jwt-skew-override'].blank?
          ENV['MAX_IAT_SKEW_SECONDS']
        else
          request.headers['x-jwt-skew-override']
        end
      end.to_i
    end

    def access_token
      request.headers['x-access-token-v2']
    end
  end
end
