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

  def self_as_json
    Jbuilder.encode do |json|
      json.(user, :id, :first_name, :last_name, :email)
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


  def staff_plan_json(company_id)
    user_projects = user.assignments.for_company(company_id)
    ww = user.work_weeks.group_by(&:project_id)
    
    Jbuilder.encode do |json|
      json.(user, :id, :full_name, :email)
      json.gravatar gravatar
      json.projects user_projects do |json, assignment|
        json.(assignment, :id, :user_id, :project_id, :proposed, :archived)
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

  def companies_as_json
    Jbuilder.encode do |json|
      json.array! user.companies do |json, company|
        json.(company, :id, :name)
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
