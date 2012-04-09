class Project < ActiveRecord::Base
  include StaffPlan::AuditMethods
  has_paper_trail
  
  attr_accessible :name, :active
  
  belongs_to  :client
  belongs_to  :company
  
  has_many :work_weeks, dependent: :destroy do
    def for_user(user)
      self.select { |ww| ww.user_id == user.id }
    end
    
    def for_user_and_cweek_and_year(user, cweek, year)
      self.for_user(user).detect { |ww| ww.cweek == cweek && ww.year == year }
    end
  end
  
  has_and_belongs_to_many :users, uniq: true
  
  after_update :update_originator_timestamp

  validates_presence_of :name, :client
  validates_uniqueness_of :name, case_sensitive: false, scope: :client_id
  
  default_scope(order: "client_id ASC, name ASC")
  
  def project_json
    Jbuilder.encode do |json|
      json.(self, :id, :client_id, :name, :active)
      
      json.users self.users do |json, user|
        json.(user, :id, :email, :first_name, :last_name, :gravatar)
        json.work_weeks user.work_weeks.for_project(self) do |json, work_week|
          json.(work_week, :id, :project_id, :actual_hours, :estimated_hours, :cweek, :year)
        end
      end
    end
  end
end
