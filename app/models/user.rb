class User < ActiveRecord::Base
  # TODO: remove password and password_confirmation from attr_accessible
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation
  has_paper_trail

  has_secure_password

  has_and_belongs_to_many :projects, uniq: true do
    def for_company(company_id)
      self.select { |p| p.company_id == company_id }
    end
  end
  
  has_and_belongs_to_many :companies, uniq: true
  
  has_many :work_weeks, dependent: :destroy do
    def for_project(project)
      self.select { |ww| ww.project_id == project.id }
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

  def administrates?(company_id)
    Company.find_by_id(company_id).administrator_id == self.id
  end

  def name
    [first_name, last_name].join(" ")
  end

  validates_presence_of :email, :name
  validates_uniqueness_of :first_name, :scope => :last_name , :case_sensitive => false
  validates_presence_of :password,  :on => :create
  validates_format_of :email,       :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/


  def gravatar
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end

  def send_registration_confirmation
    self.registration_token_sent_at = Time.now
    set_token(:registration_token)
    RegistrationMailer.registration_confirmation(self).deliver
  end

  def send_invitation
    self.registration_token_sent_at = Time.now
    set_token(:registration_token)
    RegistrationMailer.invitation(self).deliver
  end

  def self.with_registration_token(token)
    self.where("registration_token = ? AND registration_token_sent_at > ?", token, 2.hours.ago).first
  end

  # FIXME: This does NOT ensure that the token will be unique. The odds of it not being unique are virtually non-existent though
  # Two ways to handle this better:
  # Either we add an index on the tokens in the DB or some validation, I don't know...
  def set_token(column)
    self[column] = SecureRandom.urlsafe_base64
    self.save
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

  def staff_plan_json(company_id)
    Jbuilder.encode do |json|
      json.(self, :id, :name, :email, :gravatar)
      
      json.projects self.projects.for_company(company_id) do |json, project|
        json.(project, :id, :name, :client_id)
        json.work_weeks project.work_weeks.for_user(self) do |json, work_week|
          json.(work_week, :id, :project_id, :actual_hours, :estimated_hours, :cweek, :year)
        end
      end
    end
  end

end
