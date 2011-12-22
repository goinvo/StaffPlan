# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'ruby-debug'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

def login_user(user)
  session[:user_id] = user.id
end

def logout_user
  session[:user_id] = nil
end

RSpec.configure do |config|
  config.mock_with :rr
  
  config.include Mobylette::Helmet, :type => :controller
  
  config.use_transactional_fixtures = true
  
  config.infer_base_class_for_anonymous_controllers = false
end
