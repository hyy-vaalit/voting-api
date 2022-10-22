source 'https://rubygems.org'

ruby '3.1.2' # This is for Heroku, it's defined also in .ruby-version for RVM

gem 'rails', '7.0.4'

gem 'puma' # application server
gem 'grape' # API
gem 'grape-entity'
gem 'nokogiri'
gem 'pg' # Postgres
gem 'rack-cors'
gem 'jwt' # API tokens
gem 'pry-rails' # Better Rails console
gem 'pry-highlight' # pretty print json in console, usage: ">>"
gem 'rollbar' # Error reporting to Rollbar.com
gem 'oj' # Rollbar suggestion for JSON serialization if not using JRuby
gem 'ruby-saml' # Haka authentication
gem 'delayed_job_active_record' # background jobs, eg. email sending
gem 'jbuilder' # JSON builder

# Authorization
# See comment in app/api/api.rb above "include CanCan::ControllerAdditions"
# before updating cancancan.
gem 'cancancan', '3.1.0'

# Provides aws-sdk-ses
# Newer version >=3.x requires Rails >=5.2
gem "aws-sdk-rails", '~> 2.1.0'

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
  gem 'listen' #, '~> 3.0.5'  ## WAS LOCKED TO 3.1 BEFORE RAILS5
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Enable linter warnings in your editor by installing the corresponding rubocop editor plugin (eg. ruby-rubocop in VSCode)
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false

  gem "letter_opener", :group => :development # open a sent email browser

  gem 'grape_on_rails_routes' # display grape routes: `rake grape:routes`
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
