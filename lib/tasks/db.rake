namespace :db do
  desc "Untangles work weeks for cweek 1 of year 2012"
  task :untangle_work_weeks => :environment do

    WorkWeek.where(:cweek => 1, :year => 2012).all.each do |week|
      # Any week either created or updated after the 1st of March is considered a bogus week
      # Create a cweek: 1, year: 2013 version
      if (week.updated_at > Date.parse("2012/06/01")) or (week.created_at > Date.parse("2012/06/01"))
        # Copy over to 2013
        attributes = week.attributes.merge({"cweek" => 1, "year" => 2013})
        if WorkWeek.exists? attributes.slice("user_id", "project_id", "cweek", "year")
          w = WorkWeek.where(attributes.slice("user_id", "project_id", "cweek", "year")).first
          w.update_attributes(attributes.slice("estimated_hours", "actual_hours"))
        else
          ww = WorkWeek.new attributes.slice("cweek", "year", "estimated_hours", "actual_hours")
          ww.user_id = attributes["user_id"]
          ww.project_id = attributes["project_id"]
          ww.save!
        end
        # Update the 2012 version to its proper value
        if week.versions.present?
          first_version = week.versions.first
          if first_version.event == "update" and first_version.created_at > Date.parse("2012/06/01") and week.created_at < Date.parse("2012/06/01")
            w = first_version.reify
            if w.updated_at < Date.parse("2012/06/01")
              week.update_attributes(
                :estimated_hours => w.estimated_hours,
                :actual_hours => w.actual_hours 
              )
            end
          end
        else
          week.destroy
        end
      end
    end
  end
end
