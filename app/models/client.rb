class Client < ActiveRecord::Base
  attr_accessible :name, :description, :active, :company_id
  has_many :projects
  belongs_to :company

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false, scope: :company_id

  default_scope(order: "name ASC")

  def staff_plan_json
    Jbuilder.encode do |json|
      json.(self, :id, :name, :active)
      json.projects self.projects
    end
  end
end
