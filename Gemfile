source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'aws-sdk-s3', '~> 1'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'jwt'
gem 'mime-types'
gem 'puma', '~> 6.4'
gem 'rails', '~> 7.0.6'
gem 'sentry-rails', '~> 5.13'
gem 'sentry-ruby', '~> 5.13'
gem 'tzinfo-data'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'simplecov-console'
end

group :development do
  gem 'guard-rspec', require: false
end
