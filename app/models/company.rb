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

  def administrator
    User.where(id: administrator_id).first
  end

  def administrator=(user)
    self.administrator_id = user.id
    self.save
  end
  def clients_as_json
    Jbuilder.encode do |json|
      json.array! self.clients do |json, client|
      json.(client, :id, :name, :active)
        json.projects client.projects
      end
    end
  end

end
