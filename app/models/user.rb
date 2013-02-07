class User < ActiveRecord::Base

  include StaffPlan::UserRoles

  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :current_company_id, :avatar
  has_attached_file :avatar, {
    :styles => { :thumb => "70x70>" },
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
    :url => "/system/:attachment/:id/:style/:filename",
    :default_url => :default_profile_picture
  }

  has_paper_trail
  has_secure_password
  
  has_many :assignments, :dependent => :destroy do
    def for_company(company)
      self.select do |a|
        a.project.company_id == company.id
      end
    end
  end
  has_many :projects, :through => :assignments
  has_many :memberships, :dependent => :destroy
  has_many :companies, :through => :memberships, :uniq => true

  after_update do |user|
    terminator = user.versions.last.try(:terminator)
    if terminator.present? and terminator.to_i != user.id
      User.find_by_id(terminator.to_i).update_timestamp!
    end
  end

  def update_timestamp!(time = Time.now)
    self.updated_at = time
    self.save
  end

  def default_profile_picture
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end

  validates_presence_of :email, :first_name, :last_name
  validates_uniqueness_of :email
  validates_format_of :email,       :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
  
  after_validation :handle_empty_password_digest
  
  def handle_empty_password_digest
    if self.password_digest.blank? &&
       self.registration_token.present? &&
       (self.errors.keys - [:password_digest]).empty?
      self.errors.delete(:password_digest)
    end
  end
  
  def full_name
    [first_name, last_name].join(" ")
  end


  def self.with_registration_token(token)
    self.where("registration_token = ?", token).first
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

  # NOTE: https://github.com/rails/rails/pull/3887
  def save_unconfirmed_user
    self.valid?
    
    if (self.errors.keys - [:password_digest]).empty?
      save(validate: false)
      true
    else
      self.errors.delete(:password_digest)
      false
    end
  end

  # FIXME: Naive implementation of unique token
  def set_token(column)
    self[column] = SecureRandom.urlsafe_base64
    self.save_unconfirmed_user
  end

  def current_company
    companies.where(id: current_company_id).first
  end

  def current_company=(company)
    return false unless self.companies.include?(company)
    self.current_company_id = company.id
    self.save
  end

  def selectable_companies
    Company.where(id: memberships.where(disabled: false).select("memberships.company_id").pluck(:id))
  end
end
