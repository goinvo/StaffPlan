class RemoveUserIdAndProjectIdFromWorkWeeks < ActiveRecord::Migration
  def up
    remove_column(:work_weeks, :user_id)
    remove_column(:work_weeks, :project_id)
  end

  def down
    add_column(:work_weeks, :user_id, :integer)
    add_column(:work_weeks, :project_id, :integer)
    
    WorkWeek.transaction do
      WorkWeek.all.each do |ww|
        ww.user = ww.assignment.user
        ww.project = ww.assignment.project
        ww.save!
      end
    end
  end
end
