class RegistrationMailer < ActionMailer::Base
  
  def registration_notification(user, company)
    @registration_info = OpenStruct.new(:first_name => user.first_name, :last_name => user.last_name, :company_name => company.name, :email_address => user.email)
    
    if Rails.env.production?
      mail :to => User.where(:first_name => "Juhan", :last_name => "Sonin").first.email, :from => "notifier@staffplan.com", :subject => "Someone has registered a StaffPlan account"
    end
  end

  def add_staff_notification(user, company)
    @registration_info = OpenStruct.new(:first_name => user.first_name, :last_name => user.last_name, :company_name => company.name, :email_address => user.email)
    
    if Rails.env.production?
      mail :to => User.where(:first_name => "Juhan", :last_name => "Sonin").first.email, :from => "notifier@staffplan.com", :subject => "A new StaffPlan account was just created"
    end
  end
  
  def registration_confirmation user
    @user = user
    mail to: @user.email, from: "notifier@staffplan.com", subject: "Welcome to StaffPlan"
  end

  def invitation(user, inviting_user)
    @user = user
    @admin = inviting_user
    mail to: @user.email, from: "notifier@staffplan.com", subject: "You're invited to join our project planning and collaboration system"
  end

  def password_reset user
    @user = user
    mail to: @user.email, from: "notifier@staffplan.com", subject: "How to reset your StaffPlan password"
  end

end
