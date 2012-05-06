class WorkWeek < ActiveRecord::Base
  include StaffPlan::AuditMethods

  has_paper_trail
  
  attr_accessible :estimated_hours, :actual_hours, :cweek, :year
  
  belongs_to :user
  belongs_to :project

  validates_presence_of :user, :project
  validates_numericality_of :estimated_hours, :actual_hours, greater_than_or_equal_to: 0, allow_nil: true

  after_update :update_originator_timestamp 

  ################################# SCOPES ####################################

  scope :for_range, lambda { |lower, upper|
    if lower.cweek <= upper.cweek 
      where(year: lower.year, cweek: Range.new(lower.cweek,upper.cweek)) 
    else # The date range spans over two years 
      query = "(cweek >= ? AND year = ?) OR (cweek <= ? AND year = ?)"
      where(query, lower.cweek, lower.year, upper.cweek, upper.year)
    end
  }

  scope :with_hours, lambda { where("estimated_hours IS NOT NULL OR actual_hours IS NOT NULL") }  
  
  # NOTE: This assumes that we won't be showing more than 52 weeks at a time 
  # If the project evolves in a way that we're showing a whole year at a time
  # this scope should NOT be used
  scope :for_project_and_date_range, lambda { |project, lower, upper|
    WorkWeek.with_hours.for_range(lower, upper).where(project_id: project.id)
  }

end
