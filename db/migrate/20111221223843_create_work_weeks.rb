class CreateWorkWeeks < ActiveRecord::Migration
  def change
    create_table :work_weeks do |t|
      t.belongs_to        :user
      t.belongs_to        :project
      t.integer           :estimated_hours
      t.integer           :actual_hours
      t.integer           :cweek,               limit: 1
      t.integer           :year,                limit: 1
      t.timestamps
    end
    
    add_index(:work_weeks, [:user_id, :project_id, :cweek, :year], unique: true)
  end
end
