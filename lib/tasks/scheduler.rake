# This task is executed by the Heroku Scheduler add-on
desc "At the beginning of each week, this script will send emails to forgetful people"

task :send_reminders => :environment do
  if Time.now.to_date.wday == 1 # Only do this on Mondays
    year, week = *[:year, :cweek].map {|msg| Date.current.send msg}
    
    # Timestamp at begining of past week
    @timestamp = Date.commercial(year, week).to_datetime.to_i * 1000 - 7 * 86400 * 1000
    
    work_weeks_by_user = WorkWeek.where(beginning_of_week: @timestamp).all.group_by { |ww| ww.user }
    
    work_weeks_by_user.each do |user, work_weeks|
      next if user.nil?
      
      # do they care?
      if user.user_preferences.try(:email_reminder)
        # do they need a reminder? work weeks with estimates and NO actuals entered for any assignment
        # we'll assume that a single work week with actuals is a sign that they've entered their data for the week.
        has_work_weeks_with_estimates = work_weeks.any? { |ww| (ww.estimated_hours || 0) > 0 }
        has_no_work_work_weeks_with_actuals = work_weeks.none? { |ww| (ww.actual_hours || 0) > 0 }
        
        user.send_email_reminder if has_no_work_work_weeks_with_actuals && has_work_weeks_with_estimates
      end
    end
  end
end
