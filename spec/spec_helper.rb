# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'email_spec'
require 'capybara/email/rspec'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.server_port = 3456

RSpec.configure do |config|
  config.mock_with :mocha
  
  config.use_transactional_fixtures = true
  
  config.filter_run(:focus => true)
  
  config.run_all_when_everything_filtered = true
  
  config.infer_spec_type_from_file_location!
  
  config.before :each do
    PaperTrail.controller_info = {}
    PaperTrail.whodunnit = nil
  end
  
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  
  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true
  
  # Less verbose metadata
  config.treat_symbols_as_metadata_keys_with_true_values = true
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

def login_user(*options)
  options = options.extract_options!
  company = options[:company] || FactoryGirl.create(:company)
  
  user = unless options[:user].nil?
    company.users << options[:user]
    options[:user].current_company = company
    options[:user]
  else
    user = FactoryGirl.create(:user)
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

def user_with_clients_and_projects(target_user=FactoryGirl.create(:user))
  2.times do
    client = FactoryGirl.create(:client)
    2.times { FactoryGirl.create(:project, :client => client) }
  end
  
  Project.all.each do |p|
    p.assignments.create(user_id: target_user.id)
  end

  target_user
end

def company_with_users_and_projects
  FactoryGirl.create(:company).tap do |company|
    2.times do
      company.users << user_with_clients_and_projects
    end
  end
end
