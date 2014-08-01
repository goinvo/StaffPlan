class WorkWeek < ActiveRecord::Base
  has_paper_trail
  
  attr_accessible :estimated_hours, :actual_hours, :beginning_of_week, :cweek, :year
  
  belongs_to :assignment
  delegate :user, to: :assignment
  delegate :project, to: :assignment
  
  validates_presence_of :assignment, :beginning_of_week
  validates_numericality_of :estimated_hours, :actual_hours, greater_than_or_equal_to: 0, allow_nil: true
  
  before_validation :set_beginning_of_week_if_blank

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
  
  def set_beginning_of_week_if_blank
    if self.beginning_of_week.blank? && self.year.present? && self.cweek.present?
      self.beginning_of_week = Date.commercial(self.year, self.cweek).to_datetime.to_i
    end
  end

end
