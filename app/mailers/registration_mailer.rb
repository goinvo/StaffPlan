class RegistrationMailer < ActionMailer::Base
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.registration_mailer.registration_confirmation.subject
  #
  def registration_confirmation user
    @user = user
    mail to: @user.email, subject: "Welcome to StaffPlan"
  end

  def invitation user
    @user = user
    mail to: @user.email, subject: "You're invited to join our project planning and collaboration system"
  end

end
