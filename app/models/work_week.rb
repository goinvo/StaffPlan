class WorkWeek < ActiveRecord::Base
  include StaffPlan::AuditMethods
  has_paper_trail
  attr_accessible :estimated_hours, :actual_hours, :cweek, :year
  belongs_to :user
  belongs_to :project
  
  validates_presence_of :user, :project
  validates_numericality_of :estimated_hours, :actual_hours, greater_than_or_equal_to: 0, allow_nil: true

  after_update :update_originator_timestamp 
  scope :for_user_and_company, lambda { |user_id, company_id|
    date = Date.today.at_beginning_of_week
    query = "projects.company_id = ? AND work_weeks.user_id = ? AND (work_weeks.year > ? OR (work_weeks.cweek > ? AND work_weeks.year = ?))"
    joins(:project).where(query, company_id, user_id, date.year, date.cweek, date.year)
  }

end
