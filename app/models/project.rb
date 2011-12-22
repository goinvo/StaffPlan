class Project < ActiveRecord::Base
  belongs_to  :client
  has_many :work_weeks
  
  validates_presence_of :name, :client
end
