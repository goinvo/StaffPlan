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

  def self.staffplans_for_company_and_date_range(company, range)
    
    project_ids, user_ids = *[:projects, :users].map do |assoc|
      company.send(assoc).collect(&:id)
    end
    
    grouped_by_user_id = self.
        for_range(range.first, range.last).
        joins(:user).
        select("users.id as user_id, work_weeks.cweek as cweek, work_weeks.year as year, sum(work_weeks.actual_hours) as actuals, sum(work_weeks.estimated_hours) as estimates").
        where(project_id: project_ids).
        where(users: {id: user_ids}).
        group("users.id").
        group(:year).
        group(:cweek).
        group_by(&:user_id)

    {}.tap do |grouped|
      grouped_by_user_id.each do |user_id, weeks|
        grouped[user_id] = {}.tap do |sorted|
          weeks.group_by(&:year).each do |year, weeks|
            sorted[year] = weeks.sort{|a,b| a[:cweek].to_i <=> b[:cweek].to_i}.inject([]) do |memo, element|
              memo << {cweek: element.cweek.to_i, total: (Date.today.cweek > element.cweek.to_i) ? element.actuals.to_i : element.estimates.to_i}
            end
          end
        end
      end
    end 
  end

  def proposed?
    Assignment.where(project_id: self.project_id, user_id: self.user_id).first.try(:proposed?) || false
  end

end
