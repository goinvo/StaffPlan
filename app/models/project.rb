class Project < ActiveRecord::Base
  
  belongs_to  :client
  has_many :work_weeks do
    def for_user(user)
      self.select { |ww| ww.user == user }
    end
  end
  
  has_and_belongs_to_many :users, uniq: true
  
  validates_presence_of :name, :client
  
  default_scope(order: "name ASC")
end
