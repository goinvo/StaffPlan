# This task is executed by the Heroku Scheduler add-on
desc "At the beginning of each week, this script will send emails to forgetful people"

task :send_reminders => :environment do
  if Time.now.to_date.wday == 1 # Only do this on Mondays
    year, week = *[:year, :cweek].map {|msg| Date.current.send msg}
    # Timestamp at begining of past week
    @timestamp = Date.commercial(year, week).to_datetime.to_i * 1000 - 7 * 86400 * 1000 
    @users = Assignment.
                joins(:work_weeks).
                select("user_id").
                where("work_weeks.beginning_of_week = ?", @timestamp - 7 * 86400 * 1000).
                where("actual_hours IS NULL OR actual_hours = ?", 0).
                where("estimated_hours IS NOT NULL AND estimated_hours > ?", 0).
                map { |assignment| User.where(:id => assignment.user_id).first }.
                uniq

    @users.each do |user|
      if user.user_preferences.try(:email_reminder)
        user.send_email_reminder
      end
    end
  end
end

