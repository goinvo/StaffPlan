namespace :staffplan do
  namespace :db do
    desc "sanitizes the staging database. changes all passwords, person names, client names and project names"
    task :sanitize_staging => :environment do
      Bundler.with_clean_env do
        require 'faker'
        ActiveRecord::Base.establish_connection(:staging)
        
        User.all.each do |user|
          user.update_attributes(
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            password: "password",
            password_confirmation: "password"
          )
        end
        
        Company.all.each do |company|
          company.update_attributes(name: Faker::Company.name)
        end
        
        Project.all.each do |project|
          project.update_attributes(name: Faker::Company.catch_phrase)
        end
      end
    end
  end
end
