Rails.application.routes.draw do
  get '/health', to: 'health#show'
  get '/service/:service_slug/user/:user_id/:fingerprint_with_prefix', to: 'downloads#show'
  post '/service/:service_slug/user/:user_id', to: 'uploads#create'
  post '/service/:service_slug/user/:user_id/:fingerprint_with_prefix/presigned-s3-url', to: 'presigned_s3_urls#create'
end
