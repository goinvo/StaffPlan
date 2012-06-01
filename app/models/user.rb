class User < ActiveRecord::Base
 
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation
  
  has_paper_trail
  has_secure_password
  
  has_many :assignments, :dependent => :destroy
  has_many :projects, :through => :assignments do
    def for_company(company_id)
      self.select { |p| p.company_id == company_id }
    end
  end
  
  has_and_belongs_to_many :companies, uniq: true
  
  has_many :work_weeks, dependent: :destroy do
    def for_project(project)
      self.select { |ww| ww.project_id == project.id }
    end
    def for_projects(project_ids)
      self.select { |ww| project_ids.include? ww.project_id }
    end
  end

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


  validates_presence_of :email, :first_name, :last_name
  validates_format_of :email,       :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
  validates_uniqueness_of :email
  
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

  def plan_for(project_ids, from_date)
    self.work_weeks.inject(0) do |sum, ww|
      if project_ids.include?(ww.project_id) && (ww.year > from_date.year || (ww.year == from_date.year && ww.cweek >= from_date.cweek))
        sum += ww.estimated_hours || 0
      end
      
      sum
    end
  end

  

end
