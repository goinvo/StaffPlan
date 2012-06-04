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
    project_ids = current_user.current_company.projects.map(&:id)
    capture_haml do 
      if workload.present?
        range.each do |date|
          css_class = Date.today > date ? "passed" : ""
          week = workload[date.year].detect {|ww| ww[:cweek] == date.cweek}
          total = week.try(:[], :total) || 0
          proposed = WorkWeek.where(user_id: user.id, cweek: date.cweek, year: date.year, project_id: project_ids).select(&:proposed?).inject(0){ |memo, element| 
            memo += (Date.today > date) ? element.actual_hours : element.estimated_hours
          } || 0

          percentage_proposed = 100 - ((total == 0) ? 0 : (100 * proposed.to_f / total.to_f).floor)
          moz_gradient = "background-image: -moz-linear-gradient(to bottom, #5E9B69 #{percentage_proposed}%,  #7EBA8D 0%)"
          webkit_gradient = "background-image: -webkit-linear-gradient(top, #5E9B69 #{percentage_proposed}%,  #7EBA8D 0%)"

          gradient = (date <= Date.today) ? "" : [moz_gradient, webkit_gradient].join(";") 

          haml_tag(:li, {:class => css_class, :style => "height: #{total}px; #{percentage_proposed == 0 ? "" : gradient}"}) do

            haml_tag :span do
              haml_concat total.to_s
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
        json.(project, :id, :name, :client_id)
        json.proposed Assignment.where(user_id: user.id, project_id: project.id).first.try(:proposed) || false
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
