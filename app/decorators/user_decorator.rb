class UserDecorator < Draper::Base
  decorates :user
  decorates_association :project
  decorates_association :companies
  decorates_association :current_company
  denies :plan_for

  include Draper::LazyHelpers
  include Haml::Helpers

  def gravatar
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end

  def assignments_as_json
    Jbuilder.encode do |json|
      json.array! self.assignments do |json, assignment|
        json.user_id model.id
        json.project_id assignment.project_id
        json.proposed assignment.proposed
      end
    end
  end

  def permissions_information_for_company(company)
    init_haml_helpers
    m = user.memberships.where(company_id: company.id).first
    capture_haml do
      haml_tag :div, {:class => "permissions_info"} do
        haml_tag :h2 do
          haml_concat "Permissions"
        end
        if m.permissions.present?
          haml_concat "#{user.full_name} has the following permissions for company #{company.name}:"
          haml_tag :ul do
            m.permissions.each do |perm|
              haml_tag :li do
                haml_concat perm.to_s
              end
            end
          end
        else
          haml_concat "#{user.full_name} currently doesn't have any permissions for company #{company.name}"
        end
      end
    end
  end

  def employment_information_for_company(company)
    init_haml_helpers

    m = user.memberships.where(company_id: company.id).first
    capture_haml do
      haml_tag :div, {:class => "employment_information"} do
        haml_tag :h2 do
          haml_concat "Employment"
        end
        case m.employment_status
        when "fte"
          haml_tag :p do
            haml_concat "#{user.full_name} is currently a full-time employee for #{company.name}"
          end
          haml_tag :p, {:class => "employee_salary"} do
            haml_concat "Yearly salary: #{number_to_currency(m.salary.to_i, :precision => 2)}"
          end
          haml_tag :p, {:class => "full_time_equivalent"} do
            haml_concat "Full-Time Equivalent: #{number_to_currency(m.full_time_equivalent, :precision => 2)}"
          end
        when "contractor"
        when "intern"
          haml_concat "#{user.full_name} is currently an intern at #{company.name}"
        end
      end
    end
  end

  def chart_for_date_range(range)
    # FIXME: I'd like to be able to move that somewhere else
    init_haml_helpers


    project_ids = user.current_company.projects.map(&:id)
    workload = user.work_weeks.for_range(range.first, range.last).for_projects(project_ids)

    assignments = user.assignments.where(project_id: project_ids).all

    capture_haml do 
      range.each do |date|
        is_current_week = Date.today.cweek == date.cweek and Date.today.year == date.year
        load_for_week = workload.select { |ww| date.cweek == ww.cweek and date.year == ww.year }
        proposed_for_week = load_for_week.select {|ww| assignments.detect{|a| a.project_id == ww.project_id}.try(:proposed?) || false }

        msg = (date < Date.today.at_beginning_of_week or is_current_week) ? :actual_hours : :estimated_hours

        total, proposed_total = *[load_for_week, proposed_for_week].map do |w|
          w.inject(0) do |memo, week|
            memo += week.send(msg) || 0
          end
        end

        if total > 0 and msg == :actual_hours
          haml_tag :li, {:class => "actuals", :style => "height: #{total}px"} do
            haml_tag :span do
              haml_concat total.to_s
            end
          end
        else
          total = load_for_week.inject(0) do |memo, week|
            memo += week.estimated_hours || 0
          end
          proposed_total = proposed_for_week.inject(0) do |memo, week|
            memo += week.estimated_hours || 0
          end
          percentage_proposed = 100 - ((total == 0) ? 0 : (100 * proposed_total.to_f / total.to_f).floor)
          moz_gradient = "background-image: -moz-linear-gradient(to bottom, #5E9B69 #{percentage_proposed}%,  #7EBA8D 0%)"
          webkit_gradient = "background-image: -webkit-linear-gradient(top, #5E9B69 #{percentage_proposed}%,  #7EBA8D 0%)"

          gradient = [moz_gradient, webkit_gradient].join(";") 

          haml_tag(:li, {:style => "height: #{total}px; #{percentage_proposed == 0 ? "" : gradient}", "data-week" => date.cweek, "data-year" => date.year}) do
            haml_tag :span do
              haml_concat total.to_s
            end
          end
        end
      end
    end
  end

  def staff_plan_json(company_id)
    user_projects = user.assignments.for_company(company_id)
    ww = user.work_weeks.group_by(&:project_id)
    
    Jbuilder.encode do |json|
      json.(user, :id, :full_name, :email)
      json.gravatar gravatar
      json.projects user_projects do |json, assignment|
        json.(assignment, :id, :user_id, :project_id, :proposed)
        json.work_weeks ww[assignment.project_id] do |json, work_week|
          json.(work_week, :id, :project_id, :actual_hours, :estimated_hours, :cweek, :year)
        end
      end
    end
  end

  def project_json(project)
    Jbuilder.encode do |json|
      json.(user, :id, :email, :first_name, :last_name)
      json.gravatar gravatar
      json.work_weeks user.work_weeks.for_project(project) do |json, work_week|
        json.(work_week, :id, :project_id, :actual_hours, :estimated_hours, :cweek, :year)
      end
    end
  end
  
  def current_company_selector
    init_haml_helpers
    
    if current_user.selectable_companies.length > 1
      capture_haml do
        form_for current_user do |f|
          h.select(:user, :current_company_id, options_from_collection_for_select(current_user.selectable_companies, :id, :name, selected: current_user.current_company_id ))
        end
      end
    else
      current_user.current_company.try(:name) || "N/A"
    end
  end
end
