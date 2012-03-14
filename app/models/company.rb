class Company < ActiveRecord::Base
  has_paper_trail
  attr_accessible :name
  has_and_belongs_to_many :users, uniq: true
  has_many :projects
  has_many :clients

  after_update do |c|
    terminator = c.versions.last.try(:terminator)
    User.find_by_id(terminator.to_i).update_timestamp! if terminator.present?
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
