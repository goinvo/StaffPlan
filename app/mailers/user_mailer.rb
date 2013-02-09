class UserMailer < ActionMailer::Base

  def reminder(user)
    @user = user
    @url = staffplan_url(user)
    
    mail :to => user.email, :from => "notifier@staffplan.com", :subject => "StaffPlan - Weekly Reminder"
  end

end
