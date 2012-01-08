class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  
  has_secure_password
  
  has_and_belongs_to_many :projects, uniq: true
  has_many :work_weeks, :dependent => :destroy do
    def for_project(project)
      self.select { |ww| ww.project == project }
    end
  end
  
  validates_presence_of :email, :name
  validates_presence_of :password,  :on => :create
  validates_format_of :email,       :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
  
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
        work_weeks: project.work_weeks.for_user(self)
      }
    end
    
    json.to_json
  end
end
