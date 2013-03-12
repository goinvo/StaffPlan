class AddIndexToWorkWeeksAndRemoveDuplicates < ActiveRecord::Migration
  def change

    # First let us clean up the duplicates

    @statement = <<-SQL
      SELECT 
        w1.id
      FROM 
        work_weeks w1,
        work_weeks w2
      WHERE
          w1.id <> w2.id
        AND
          w1.assignment_id = w2.assignment_id
        AND
          w1.beginning_of_week = w2.beginning_of_week
    SQL

    @rows = ActiveRecord::Base.connection.execute @statement

    @weeks = WorkWeek.where(:id => @rows.map { |elem| elem['id'] }).all

    @grouped = @weeks.group_by do |elem|
      "#{elem.assignment_id}-#{elem.beginning_of_week}"
    end

    @grouped.each do |key, weeks|
      # First pass
      # For all duplicates where the estimated_hours and actual_hours are nil, we can delete everything
      if weeks.all? { |week| week.estimated_hours.nil? and week.actual_hours.nil? }
        weeks.each do |w|
          w.destroy
        end
      end

      # Second pass
      # For the rest of the weeks, we keep only keep one copy if the attributes are identical across all duplicates
      first_week = weeks.first.attributes.slice("estimated_hours", "actual_hours", "cweek", "year")
      if weeks.all? { |week| week.attributes.slice("estimated_hours", "actual_hours", "cweek", "year") == first_week }
        weeks.slice(1..-1).each do |w|
          w.destroy
        end
      end

      # Finally, third pass
      # We keep the last updated version of the duplicate, it's the one we're supposed to trust
      weeks.sort { |a,b| a.updated_at <=> b.updated_at }.last.destroy

    end
    WorkWeek.reset_column_information

    add_index :work_weeks, [:assignment_id, :beginning_of_week], :unique => true
  end
end
