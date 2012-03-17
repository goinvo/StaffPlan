require 'simplecov'
SimpleCov.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

def login_user(*options)
  options = options.extract_options!
  company = options[:company] || Factory(:company)
  
  user = unless options[:user].nil?
    company.users << options[:user]
    options[:user].current_company = company
    options[:user]
  else
    user = Factory(:user)
    company.users << user
    user.current_company = company
    user
  end
  
  session[:user_id] = user.id
  
  return user, company
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

def with_versioning
  was_enabled = PaperTrail.enabled?
  PaperTrail.enabled = true
  begin
    yield
  ensure
    PaperTrail.enabled = was_enabled
  end
end


RSpec.configure do |config|
  config.mock_with :mocha
  
  config.use_transactional_fixtures = true
  
  config.filter_run(:focus => true)
  
  config.run_all_when_everything_filtered = true

  config.before :each do
    PaperTrail.controller_info = {}
    PaperTrail.whodunnit = nil
  end
end
