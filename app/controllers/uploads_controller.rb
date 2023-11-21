class UploadsController < ApplicationController
  include Concerns::JWTAuthentication

  before_action :check_upload_params, only: [:create]

  def create
    @file_manager = FileManager.new(
      encoded_file: params[:file],
      user_id: params[:user_id],
      service_slug: params[:service_slug],
      encrypted_user_id_and_token: params[:encrypted_user_id_and_token],
      bucket: bucket,
      options: {
        max_size: params[:policy][:max_size],
        allowed_types: params[:policy][:allowed_types],
        days_to_live: params[:policy][:expires]
      }
    )

    log('Created file manager, saving to disk...')
    @file_manager.save_to_disk
    log('Saved file to disk')

    if @file_manager.file_too_large?
      log('File is too large')
      return error_large_file(@file_manager.file_size)
    end

    unless @file_manager.type_permitted?
      log('File type is not permitted')
      return error_unsupported_file_type(@file_manager.mime_type)
    end

    log('Virus check starting...')
    if @file_manager.has_virus?
      return error_virus_error
    end
    log('Virus check finished. Checking if file already exists')

    if @file_manager.file_already_exists?
      log('File exists, returning')
      hash = {
        fingerprint: "#{@file_manager.fingerprint_with_prefix}",
        size: @file_manager.file_size,
        type: @file_manager.mime_type,
        date: @file_manager.expires_at.to_i
      }

      render json: hash, status: :ok
    else
      # async?
      log('Uploading file...')
      @file_manager.upload
      log('Upload to remote storage complete, returning')
      hash = {
        fingerprint: "#{@file_manager.fingerprint_with_prefix}",
        size: @file_manager.file_size,
        type: @file_manager.mime_type,
        date: @file_manager.expires_at.to_i
      }

      render json: hash, status: 201
    end
  rescue StandardError => e
    Sentry.capture_exception(e)
    log("Unexpected error: #{e}")
    return error_upload_server_error
  ensure
    @file_manager.delete_file if @file_manager
  end

  private

  def check_upload_params
    log('Checking upload params...')

    if params[:file].blank?
      return render json: { code: 400, name: 'error.file-missing' }, status: 400
    end

    if params[:user_id].blank?
      return render json: { code: 400, name: 'error.user-id-missing' }, status: 400
    end

    unless @jwt_payload['sub'] == params[:user_id]
      log('There is a mismatch between the user_id and the jwt sub')
      return render json: { code: 403, name: 'error.user-id-sub-mismatch' }, status: 403
    end

    if params[:encrypted_user_id_and_token].blank?
      return render json: { code: 403, name: 'error.user-id-token-missing' }, status: 403
    end

    if params[:service_slug].blank?
      return render json: { code: 400, name: 'error.service-slug-missing' }, status: 400
    end

    if params[:policy].blank?
      return render json: { code: 400, name: 'error.policy-missing' }, status: 400
    end

    if params[:policy][:max_size].blank?
      return render json: { code: 400, name: 'error.policy-max-size-missing' }, status: 400
    end

    if params[:policy][:allowed_types].blank?
      params[:policy][:allowed_types] = ['*/*']
    end

    if params[:policy][:expires].blank?
      params[:policy][:expires] = 28
    end
  end

  def error_large_file(size)
    render json: { code: 400,
                   name: 'invalid.too-large',
                   max_size: params[:policy][:max_size],
                   size: size }, status: 400
  end

  def error_unsupported_file_type(type)
    render json: { code: 400,
                   name: 'accept',
                   type: type }, status: 400
  end

  def error_upload_server_error
    render json: { code: 503,
                   name: 'error.file-store-failed' }, status: 503
  end

  def error_virus_error
    render json: { code: 400,
                   name: 'invalid.virus' }, status: 400
  end

  def log(str)
    Rails.logger.info("[#{self.class.name}] #{str}")
  end

  def bucket
    ENV['AWS_S3_BUCKET_NAME']
  end
end
