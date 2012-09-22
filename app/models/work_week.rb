class WorkWeek < ActiveRecord::Base
  include StaffPlan::AuditMethods

  has_paper_trail
  
  attr_accessible :estimated_hours, :actual_hours, :cweek, :year
  
  belongs_to :assignment
  delegate :user, to: :assignment
  delegate :project, to: :assignment
  
  validates_presence_of :assignment
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
  
  def proposed?
    project.assignments.where(user_id: user.id).first.try(:proposed?) || false
  end

end
