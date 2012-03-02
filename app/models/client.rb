class Client < ActiveRecord::Base
  has_many :projects
  belongs_to :company
  
  validates_presence_of :name
  
  default_scope(order: "name ASC")
  
  def staff_plan_json
    Jbuilder.encode do |json|
      json.(self, :id, :name, :active)
      json.projects self.projects do |json, project|
        attrs = (Project.columns_hash.keys - %w(updated_at created_at id)).map(&:to_sym)
        json.(project, *attrs)
      end
    end
  end
end
