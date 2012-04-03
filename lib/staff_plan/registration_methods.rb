require "active_support/concern"

module StaffPlan::RegistrationMethods
  extend ActiveSupport::Concern

  module ClassMethods
    def with_registration_token(token)
      where("registration_token = ?", token).first
    end
  end

  def send_registration_confirmation
    set_token(:registration_token)
    RegistrationMailer.registration_confirmation(self).deliver
  end

  def send_invitation(inviting_user)
    set_token(:registration_token)
    RegistrationMailer.invitation(self, inviting_user).deliver
  end
  
  def send_password_reset_instructions
    self.registration_token = SecureRandom.urlsafe_base64
    self.save 
    RegistrationMailer.password_reset(self).deliver
  end

  # XXX: https://github.com/rails/rails/pull/3887
  def save_unconfirmed_user
    self.valid?
    
    if (self.errors.keys - [:password_digest]).empty?
      save(validate: false)
      true
    else
      false
    end
  end

  # FIXME: Naive implementation of unique token
  def set_token(column)
    self[column] = SecureRandom.urlsafe_base64
    self.save_unconfirmed_user
  end

end
