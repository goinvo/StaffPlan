class WorkWeek < ActiveRecord::Base
  include StaffPlan::AuditMethods
  has_paper_trail
  attr_accessible :estimated_hours, :actual_hours, :cweek, :year
  belongs_to :user
  belongs_to :project
  
  validates_presence_of :user, :project
  validates_numericality_of :estimated_hours, :actual_hours, greater_than_or_equal_to: 0, allow_nil: true

  after_update :update_originator_timestamp 

end
