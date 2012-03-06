class Project < ActiveRecord::Base
  
  attr_accessible :client, :name, :active, :company 
  
  belongs_to  :client
  belongs_to  :company
  
  has_many :work_weeks, dependent: :destroy do
    def for_user(user)
      self.select { |ww| ww.user_id == user.id }
    end
    
    def for_user_and_cweek_and_year(user, cweek, year)
      self.for_user(user).detect { |ww| ww.cweek == cweek && ww.year == year }
    end
  end
  
  has_and_belongs_to_many :users, uniq: true
  
  validates_presence_of :name, :client
  validates_uniqueness_of :name, case_sensitive: false, scope: :company_id
  
  default_scope(order: "client_id ASC, name ASC")
end
