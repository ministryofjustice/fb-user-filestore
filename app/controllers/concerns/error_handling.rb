module Concerns
  module ErrorHandling
    extend ActiveSupport::Concern

    included do
      rescue_from StandardError do |e|
        Sentry.capture_exception(e)

        args = { message: e.message }
        unless Rails.env.production?
          args.merge!(
            detail: e.class.name.underscore.to_sym,
            location: e.backtrace[0]
          )
        end
        render_json_error :internal_server_error, :internal_server_error, args
      end
    end

    private

    def render_json_error(status, error_code, extra = {})
      if status.is_a? Symbol
        status = (Rack::Utils::SYMBOL_TO_STATUS_CODE[status] || 500)
      end

      error = {
        title: I18n.t(:title, scope: [:error_messages, error_code]),
        status: status
      }.merge(extra)

      detail = I18n.t(:detail, scope: [:error_messages, error_code], default: '')
      error[:detail] = detail unless detail.empty?

      # NOTE: upload responses need to conform to a specific format
      # to be understood by the frontend
      if is_a?(UploadsController)
        render json: { code: status, name: "error.#{error_code}" }, status:
      else
        render json: { errors: [error] }, status:
      end
    end
  end
end
