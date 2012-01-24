class Client < ActiveRecord::Base
  has_many :projects
  
  validates_presence_of :name
  
  default_scope(order: "name ASC")
  
  def self.staff_plan_json
    all.as_json(:only => [:id, :name, :active], include: :projects)
  end
end
