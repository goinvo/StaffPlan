json.(project, :id, :name, :client_id)
json.work_weeks project.work_weeks.for_user(@user) do |json, work_week|
  json.(work_week, :id, :project_id, :actual_hours, :estimated_hours, :cweek, :year)
end
