if Rails.env.development?
  # Prefer an explicit endpoint via ENV to support running inside/outside Docker seamlessly.
  # Default to the Docker Compose service name ("localstack") so the API container
  # can reach LocalStack over the Docker network. If you run the app on the host
  # (not in Docker), set AWS_ENDPOINT to "http://localhost.localstack.cloud:4566".
  endpoint = ENV['AWS_ENDPOINT'] || 'http://localstack:4566'

  Aws.config.update(
    endpoint: endpoint,
    credentials: Aws::Credentials.new('qwerty', 'qwerty'),
    region: 'us-east-1',
    force_path_style: true,
  )
end
