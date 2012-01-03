class CreateWorkWeeks < ActiveRecord::Migration
  def change
    create_table :work_weeks do |t|
      t.belongs_to        :user
      t.belongs_to        :project
      t.decimal           :estimated_hours,     scale: 1
      t.decimal           :actual_hours,        scale: 1
      t.integer           :cweek,               limit: 1
      t.integer           :year,                limit: 1
      t.timestamps
    end
  end
end
