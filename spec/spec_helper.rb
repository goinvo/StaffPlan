# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'ruby-debug'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

def login_user(user=Factory(:user))
  session[:user_id] = user.id
end

def logout_user
  session[:user_id] = nil
end

def user_with_clients_and_projects(target_user=Factory(:user))
  2.times do
    client = Factory(:client)
    2.times { Factory(:project, :client => client) }
  end
  
  Project.all.each { |p| p.users << target_user }
  
  target_user
end

RSpec.configure do |config|
  config.mock_with :mocha
  
  config.include Mobylette::Helmet, :type => :controller
  
  config.use_transactional_fixtures = true
  
  config.filter_run(:focus => true)
  
  config.run_all_when_everything_filtered = true
end
