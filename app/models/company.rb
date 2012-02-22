class Company < ActiveRecord::Base

  has_and_belongs_to_many :users, uniq: true
  has_many :projects

  def clients
    Client.joins(:projects).where("projects.company_id = ?", self.id) 
  end
end
