class HealthController < ActionController::API
  # used by liveness probe
  def show
    render plain: 'healthy'
  end

  def readiness
    if internal_bucket_client.head_bucket({ bucket: ENV.fetch('AWS_S3_BUCKET_NAME') })
      render plain: 'ready'
    end
  end

  private

  def internal_bucket_client
    Aws::S3::Client.new
  end
end
