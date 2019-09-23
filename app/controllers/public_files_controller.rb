class PublicFilesController < ApplicationController
  before_action :check_params, only: [:create]

  def create
    # 1. Download File
    file_data = downloader.contents
    # 2. Generate key
    encryption_key = ssl.random_key
    encryption_iv = ssl.random_iv

    # 3. Re-encrypt file
    reencrypted_file_data = Cryptography.new(
      encryption_key: encryption_key,
      encryption_iv: encryption_iv
    ).encrypt(file: file_data)

    # 4. Send to S3
    uploader.upload(file_data: reencrypted_file_data)

    # 5. Generate signed S3 url
    # TODO


    # 6. Return URL and key
    payload = {
      encryption_key: Base64.strict_encode64(encryption_key),
      encryption_iv: Base64.strict_encode64(encryption_iv)
    }

    render json: payload.to_json, status: 201
  end

  private

  def ssl
    @ssl ||= OpenSSL::Cipher.new 'AES-256-CBC'
  end

  def downloader
    @downloader ||= Storage::S3::Downloader.new(key: key, bucket: bucket)
  end

  def uploader
    @uploader ||= Storage::S3::Uploader.new(key: key, bucket: public_bucket)
  end

  def key
    @key ||= KeyForFile.new(
      user_id: params[:user_id],
      service_slug: params[:service_slug],
      file_fingerprint: file_fingerprint,
      days_to_live: 1,
      cipher_key: cipher_key
    ).call
  end

  def bucket
    ENV['AWS_S3_BUCKET_NAME']
  end


  def public_bucket
    ENV['AWS_S3_PUBLIC_BUCKET_NAME']
  end

  def file_fingerprint
    params[:url].split('/').last
  end

  def cipher_key
    Digest::MD5.hexdigest(request.headers['x-encrypted-user-id-and-token'])
  end

  def check_params
    if params[:url].blank?
      return render json: { code: 400, name: 'invalid.url-missing' }, status: 400
    end
  end
end
