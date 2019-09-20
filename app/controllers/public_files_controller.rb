class PublicFilesController < ApplicationController
  before_action :check_params, only: [:create]

  def create
    unencrypted_file = downloader.contents
    # TODO:
    # 1. Download File DONE
    # 2. Generate key
    # 3. Re-encrypt file
    # 4. Send to S3
    # 5. Generate signed S3 url
    # 6. Return URL and key

    render json: {}, status: 201
  end

  private

  def downloader
    @downloader ||= Storage::S3::Downloader.new(key: key, bucket: bucket)
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
