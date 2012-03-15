class User < ActiveRecord::Base
  # TODO: remove password and password_confirmation from attr_accessible
  attr_accessible :name, :email, :password, :password_confirmation

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

  validates_presence_of :email, :name
  validates_uniqueness_of :name, case_sensitive: false
  validates_presence_of :password,  :on => :create
  validates_format_of :email,       :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/

  def gravatar
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end

  def current_company
    companies.where(id: current_company_id).first
  end
  
  def current_company=(company)
    return false unless self.companies.include?(company)
    self.current_company_id = company.id
    self.save
  end

  def plan_for(project_ids)
    date = Date.today.at_beginning_of_week
    
    self.work_weeks.inject(0) do |sum, ww|
      if project_ids.include?(ww.project_id) && (ww.year > date.year || (ww.year == date.year && ww.cweek >= date.cweek))
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
