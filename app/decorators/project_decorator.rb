class ProjectDecorator < Draper::Base
  
  decorates :project
  
  include Draper::LazyHelpers
  include Haml::Helpers

  def project_json
    Jbuilder.encode do |json|
      json.(self, :id, :client_id, :name, :active)
      json.cost self.cost.to_i
      json.payment_frequency self.payment_frequency == "total" ? "total" : "per month"
      json.users self.users do |json, user|
        json.(user, :id, :email, :first_name, :last_name)
        json.gravatar UserDecorator.new(user).gravatar
        json.work_weeks user.work_weeks.for_project(self) do |json, work_week|
          json.(work_week, :id, :project_id, :actual_hours, :estimated_hours, :cweek, :year)
        end
      end
    end
  end

  def info_and_controls
    # Needed to be able to use HAML helpers
    init_haml_helpers
    capture_haml do
      haml_tag :li do
        haml_tag :a, {:href => url_for(model)} do
          haml_tag(:span, :class => "client-name") do
            haml_concat model.client.try(:name) || "N/A"
          end
          haml_tag(:span, :class => "project-name") do
            haml_concat model.name 
          end
          haml_tag(:span) do
            project.proposed_for_user?(current_user) ? "Proposed" : ""
          end
        end
        haml_tag(:div, :class => "controls") do
          haml_concat link_to("Edit", edit_project_path(model))
        end
      end
    end
  end  
  
  def assignments_as_json
    Jbuilder.encode do |json|
      json.array! self.assignments do |json, assignment|
        json.project_id model.id
        json.user_id assignment.user_id
        json.proposed assignment.proposed
      end
    end
  end


  def chart_for_date_range(range)
    # Needed to be able to use HAML helpers
    init_haml_helpers
    
    workload = project.work_weeks.for_range(range.first, range.last)
    assignments = project.assignments

    capture_haml do  
      range.each do |date|
        is_current_week = (date.year == Date.today.year && date.cweek == Date.today.cweek)
        load_for_week = workload.select { |ww| ww.cweek == date.cweek and ww.year == date.year }
        proposed_for_week = load_for_week.select { |ww| assignments.detect{ |a| a.user_id == ww.assignment.user_id }.try(:proposed?) || false }
        msg = (((date.cweek < Date.today.at_beginning_of_week.cweek) && (date.year <= Date.today.at_beginning_of_week.year)) || is_current_week) ? :actual_hours : :estimated_hours
        total = load_for_week.inject(0) { |memo, week| memo += week.send(msg) || 0 }

        if (total > 0 && msg == :actual_hours)
          haml_tag :li, {:class => "actuals", :style => "height: #{total}px", "data-week" => date.cweek, "data-year" => date.year} do
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
          percentage_proposed = total == 0 ? 0 : (100 * proposed_total.to_f / total.to_f).floor
          moz_gradient = "background-image: -moz-linear-gradient(to top, #7EBA8D #{percentage_proposed}%, #5E9B69 0%)"
          webkit_gradient = "background-image: -webkit-linear-gradient(bottom, #7EBA8D #{percentage_proposed}%, #5E9B69 0%)"

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

end
