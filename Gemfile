source 'https://rubygems.org'

ruby '4.0.5' # This is for Heroku, it's defined also in .ruby-version for RVM

gem 'rails', '8.1.3'

gem 'puma' # application server
gem 'grape' # API
gem 'grape-entity'
gem 'nokogiri'
gem 'pg' # Postgres
gem 'rack-cors'
gem 'jwt' # API tokens
gem 'rollbar' # Error reporting to Rollbar.com
gem 'oj' # Rollbar suggestion for JSON serialization if not using JRuby
gem 'ruby-saml' # Haka authentication
gem 'delayed_job_active_record' # background jobs, eg. email sending
gem 'jbuilder' # JSON builder
gem 'csv'
gem 'logger'

# Authorization
# See comment in app/api/api.rb above "include CanCan::ControllerAdditions"
# before updating cancancan.
gem 'cancancan', '3.5.0'

gem 'aws-sdk-rails', '~> 5'
gem 'aws-actionmailer-ses', '~> 1'

group :development, :test do
  gem 'byebug', platform: :mri # usage: write 'debugger' anywhere in code
  gem 'rspec'
  gem 'rspec-rails'
  gem 'guard-rspec', require: false
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'database_cleaner'
  gem 'solargraph'
end

group :development do
  gem 'foreman'
  gem 'listen'

  # Enable linter warnings in your editor by installing the corresponding rubocop editor plugin (eg. ruby-rubocop in VSCode)
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false

  gem "letter_opener", :group => :development # open a sent email browser

  gem 'grape_on_rails_routes' # display grape routes: `rake grape:routes`
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
