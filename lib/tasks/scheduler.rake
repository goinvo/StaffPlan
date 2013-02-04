# This task is executed by the Heroku Scheduler add-on
desc "At the beginning of each week, this script will send emails to forgetful people"

task :send_reminders => :environment do
  # Go through all the users, find out the offenders and send them an email
end

