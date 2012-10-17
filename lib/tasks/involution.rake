namespace :db do
  desc "Associate Bertrand to Involution Studios for testing"
  task :involution => :environment do
    if Rails.env.development?

      @user = User.where({
        first_name: "Bertrand", 
        last_name: "Chardon",
        email: "bertrand.chardon@gmail.com"
      }).first

      @company = Company.where({
        name: "Involution Studios"
      }).first

      unless [@company, @user].any? { |variable| variable.nil? }
        begin
          @company.users << @user
          @user.current_company_id = @company.id
          @user.save
        rescue => kaboom
          puts "ERROR WHILE SAVING: #{kaboom}"
        end 
        puts "DONE !!!"
      end
    end
  end
end
