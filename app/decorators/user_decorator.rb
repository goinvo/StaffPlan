class UserDecorator < Draper::Base
  decorates :user
  denies :plan_for

  include Draper::LazyHelpers
  include Haml::Helpers

  def gravatar
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end
  
  def chart_for_date_range(workload, range)
    init_haml_helpers
    capture_haml do 
      if workload.present?
        range.each do |date|
          week = workload[date.year].detect {|ww| ww[:cweek] == date.cweek}
          haml_tag :li, {:class => "#{Date.today.cweek >= date.cweek ? "passed" : ""}", :style => "height: #{week.try(:[], :total) || 0}px"} do
            haml_tag :span do
              haml_concat (week.try(:[], :total) || 0).to_s
            end
          end
        end
      else
        range.size.times do
          haml_tag :li, {:style => "height: 0px"} do
            haml_tag :span do
              haml_concat "0"
            end
          end
        end
      end
    end
  end

  def staff_plan_json(company_id)
    user_projects = user.projects.for_company(company_id)
    ww = user.work_weeks.group_by(&:project_id)
    Jbuilder.encode do |json|
      json.(user, :id, :full_name, :email)
      json.gravatar gravatar
      json.projects user_projects do |json, project|
        json.(project, :id, :name, :client_id, :proposed)
        json.work_weeks ww[project.id] do |json, work_week|
          json.(work_week, :id, :project_id, :actual_hours, :estimated_hours, :cweek, :year)
        end
      end
    end
  end
  
  def project_json(project)
    Jbuilder.encode do |json|
      json.(user, :id, :email, :first_name, :last_name, :gravatar)
      json.work_weeks user.work_weeks.for_project(project) do |json, work_week|
        json.(work_week, :id, :project_id, :actual_hours, :estimated_hours, :cweek, :year)
      end
    end
  end
end
