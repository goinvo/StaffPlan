class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  
  has_secure_password
  
  has_and_belongs_to_many :projects, uniq: true
  has_and_belongs_to_many :companies, uniq: true
  has_many :work_weeks, :dependent => :destroy do
    def for_project(project)
      self.select { |ww| ww.project == project }
    end
  end
  
  validates_presence_of :email, :name
  validates_presence_of :password,  :on => :create
  validates_format_of :email,       :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
  
  def gravatar
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end

  # TODO: custom finder SQL
  def staff_plan_json
    json = {
      id: self.id,
      name: self.name,
      email: self.email,
      projects: []
    }
    
    self.projects.each do |project|
      json[:projects] << {
        id: project.id,
        name: project.name,
        client_id: project.client_id,
        work_weeks: project.work_weeks.for_user(self).map do |ww|
          { id: ww.id,
            project_id: ww.project_id,
            actual_hours: ww.actual_hours,
            estimated_hours: ww.estimated_hours,
            cweek: ww.cweek,
            year: ww.year }
        end
      }
    end
    
    json.to_json
  end
end
