class AssociateWorkWeeksWithAssignments < ActiveRecord::Migration
  def up
    # a little data clean up, some orphaned work weeks exist in production
    WorkWeek.all.each do |ww|
      ww.destroy if Assignment.where(user_id: ww.user_id).where(project_id: ww.project_id).first.nil?
    end
    
    add_column(:work_weeks, :assignment_id, :integer)
    add_column(:assignments, :created_at, :timestamp)
    add_column(:assignments, :updated_at, :timestamp)
    Assignment.all.map(&:touch)
    
    problems = []
    
    WorkWeek.transaction do
      WorkWeek.all.each do |work_week|
        assignment = Assignment.where(user_id: work_week.user_id, project_id: work_week.project_id).first
        problems << work_week if assignment.nil?
        work_week.assignment = assignment
        work_week.save!
      end
    end
    
    puts "problems? #{problems.empty? ? 'no' : problems.map(&:id).join(', ')}"
  end

  def down
    add_column(:assignments, :created_at)
    add_column(:assignments, :updated_at)
    remove_column(:work_weeks, :assignment_id)
  end
end
