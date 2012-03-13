class WorkWeek < ActiveRecord::Base
  attr_accessible :estimated_hours, :actual_hours, :cweek, :year
  belongs_to :user
  belongs_to :project
  
  validates_presence_of :user, :project
  validates_numericality_of :estimated_hours, :actual_hours, greater_than_or_equal_to: 0, allow_nil: true

  scope :for_user_and_company, lambda { |user_id, company_id|
    joins(:project).where("projects.company_id = ? AND work_weeks.user_id = ? AND cweek > ?", company_id, user_id, Date.today.at_beginning_of_week.cweek)
  }

end
