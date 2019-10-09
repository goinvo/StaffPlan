source 'http://rubygems.org'
ruby "2.1.3"

gem 'rails', '3.2.20'

gem 'backbone-support',  '0.3.0'
gem 'bcrypt-ruby',       '~> 3.0.1'
gem 'json', '~> 1.7'
gem 'bitmask_attributes'
gem 'coffee-filter'
gem 'draper',             '0.18.0'
gem 'haml-rails'
gem 'jbuilder'
gem 'mobile-fu'
gem 'paper_trail',       '~> 2.7'
gem 'pg'
gem "bower-rails",       "~> 0.7.3"
gem 'sass-rails',        '~> 3.2'
gem 'thin'
gem 'newrelic_rpm'
gem 'compass-rails'
gem 'git'
gem 'figaro'
gem 'asset_sync'
gem 'active_model_serializers'
gem 'handlebars_assets'
gem "airbrake"

group :assets do
  gem 'coffee-rails', '~> 3.2'
  gem 'uglifier',     '>= 1.0'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 2.99'
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-remote',                               require: 'pry-remote'
  gem 'faker'
  gem 'spring'
end

group :development do
  gem 'awesome_print',                            require: 'ap'
  gem 'quiet_assets'
  gem 'sqlite3'
  gem 'taps'
end

group :test do
  gem 'factory_girl_rails'
  gem 'mocha',                                   require: false
  gem 'nokogiri'
  gem 'timecop'
  gem 'capybara'
  gem 'capybara-email',             github: 'dockyard/capybara-email'
  gem 'capybara-screenshot'
  gem 'selenium-webdriver'
  gem 'email_spec'
  gem 'capybara-webkit'
  gem 'database_cleaner'
end

group :production do
  gem 'memcache-client'
  gem 'unicorn'
end
