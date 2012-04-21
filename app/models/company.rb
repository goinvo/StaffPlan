class Company < ActiveRecord::Base
  include StaffPlan::AuditMethods
  has_paper_trail
  attr_accessible :name
  has_and_belongs_to_many :users, uniq: true
  has_many :projects, dependent: :destroy
  has_many :clients, dependent: :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name

  after_update :update_originator_timestamp 
  
  def users_json
    Jbuilder.encode do |json|
      json.array! self.users do |json, user|
        json.(user, :id, :full_name, :email)
      end
    end
  end
  
  def clients_as_json
    Jbuilder.encode do |json|
      json.array! self.clients do |json, client|
      json.(client, :id, :name, :active)
        json.projects client.projects
      end
    end
  end

  def self.all_with_users_and_projects
    Jbuilder.encode do |json|
      json.companies self.all do |json, company|
        json.(company, :name)
        json.users company.users do |json, user|
          json.(user, :id, :first_name, :last_name)
          json.project_ids user.projects.map(&:id)
        end
        json.projects company.projects do |json, project|
          json.(project, :id, :name)
          json.client_name project.client.name.strip
          json.user_ids project.users.map(&:id)
        end
      end
    end
  end

end
