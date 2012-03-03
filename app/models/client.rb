class Client < ActiveRecord::Base
  has_many :projects
  belongs_to :company

  validates_presence_of :name

  default_scope(order: "name ASC")

  def staff_plan_json
    Jbuilder.encode do |json|
      json.(self, :id, :name, :active)
      json.projects self.projects
    end
  end
end
