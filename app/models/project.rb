class Project < ActiveRecord::Base
  
  belongs_to  :client
  has_many :work_weeks
  has_and_belongs_to_many :users, uniq: true
  
  validates_presence_of :name, :client
  
end
