class Company < ActiveRecord::Base

  has_and_belongs_to_many :users, uniq: true
  has_many :projects
  has_many :clients

  def clients_as_json
    Jbuilder.encode do |json|
      json.clients self.clients do |json, client|
      json.(client, :id, :name, :active)
        json.projects client.projects
      end
    end
  end

end
