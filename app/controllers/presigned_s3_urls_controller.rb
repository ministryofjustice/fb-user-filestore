class PresignedS3UrlsController < ApplicationController
  def create
    render json: {}, status: 201
  end
end
