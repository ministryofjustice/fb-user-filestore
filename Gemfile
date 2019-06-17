source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails', '~> 5.2.1', '>= 5.2.1.1'
gem 'puma', '~> 3.11'
gem 'aws-sdk-s3', '~> 1'
gem 'jwt'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8'
  gem 'dotenv-rails'
end

group :test do
  gem 'timecop'
end

group :development do
   gem 'guard-rspec', require: false
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
