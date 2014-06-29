namespace :staffplan do
  namespace :db do
    desc "sanitizes the staging database. changes all passwords, person names, client names and project names"
    task :sanitize_staging => :environment do
      Bundler.with_clean_env do
        require 'faker'
        # todo: sanitize
      end
    end
  end
end
