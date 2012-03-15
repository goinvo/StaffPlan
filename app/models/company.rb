class Company < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :users, uniq: true
  has_many :projects, dependent: :destroy
  has_many :clients, dependent: :destroy
  
  validates_presence_of :name

  def clients_as_json
    Jbuilder.encode do |json|
      json.array! self.clients do |json, client|
      json.(client, :id, :name, :active)
        json.projects client.projects
      end
    end
  end

end
