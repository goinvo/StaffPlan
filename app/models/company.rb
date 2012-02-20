class Company < ActiveRecord::Base

  has_and_belongs_to_many :users, uniq: true
  has_many :projects

  def clients
    # Easy way about it. We could also maintain another join table for the association between
    # clients and companies/accounts but is it worth it?
    Client.joins(:projects).where("projects.company_id = ?", self.id) 
  end
end
