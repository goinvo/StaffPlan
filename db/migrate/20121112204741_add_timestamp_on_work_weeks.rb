class AddTimestampOnWorkWeeks < ActiveRecord::Migration
  def up
    add_column :work_weeks, :beginning_of_week, :decimal, :precision => 15, :scale => 0

    WorkWeek.reset_column_information
    weeks = WorkWeek.all
    
    weeks.each do |week|
      week.beginning_of_week = Date.commercial(week.year, week.cweek, 1).to_datetime().to_i * 1000
      week.save
    end
  end

  def down
    remove_column :work_weeks, :beginning_of_week
  end
end
