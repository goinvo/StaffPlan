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
        json.work_weeks self.assignments.where(user_id: user.id).first.work_weeks do |json, work_week|
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
end
