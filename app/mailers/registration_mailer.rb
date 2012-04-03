class RegistrationMailer < ActionMailer::Base
  def registration_confirmation user
    @user = user
    mail to: @user.email, subject: "Welcome to StaffPlan"
  end

  def invitation(user, inviting_user)
    @user = user
    @admin = inviting_user 
    mail to: @user.email, subject: "You're invited to join our project planning and collaboration system"
  end

  def password_reset user
    @user = user
    mail to: @user.email, subject: "How to reset your StaffPlan password"
  end

end
