source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'aws-sdk-s3', '~> 1'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'jwt'
gem 'mime-types'
gem 'metrics_adapter', '0.2.0'
gem 'puma', '~> 5.6'
gem 'rails', '~> 6.1.7', '< 7.0.0.0'
gem 'sentry-rails', '~> 5.5.0'
gem 'sentry-ruby', '~> 5.5.0'
gem 'tzinfo-data'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 6.0'
end

group :test do
  gem 'timecop'
end

group :development do
   gem 'guard-rspec', require: false
end
