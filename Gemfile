source 'http://rubygems.org'
ruby "2.1.2"

gem 'rails', '3.2.18'

gem 'backbone-support',  '0.3.0'
gem 'bcrypt-ruby',       '~> 3.0.1'
gem 'json', '~> 1.7'
gem 'bitmask_attributes'
gem 'coffee-filter'
gem 'draper',             '0.18.0'
gem 'faker'
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

group :assets do
  gem 'coffee-rails', '~> 3.2'
  gem 'uglifier',     '>= 1.0'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.0'
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-remote',                               require: 'pry-remote'
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
end

group :production do
  gem 'memcache-client'
  gem 'unicorn'
end
