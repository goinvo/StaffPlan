class ProjectDecorator < Draper::Base
  
  decorates :project
  
  include Draper::LazyHelpers
  include Haml::Helpers

  def project_json
    Jbuilder.encode do |json|
      json.(self, :id, :client_id, :name, :active)

      json.users self.users do |json, user|
        json.(user, :id, :email, :first_name, :last_name, :gravatar)
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
      haml_tag :li, :class => (project.proposed? ? "proposed" : "") do
        haml_tag :a, {:href => url_for(model)} do
          haml_tag(:span, :class => "client-name") do
            haml_concat model.client.try(:name) || "N/A"
          end
          haml_tag(:span, :class => "project-name") do
            haml_concat model.name 
          end
          haml_tag(:span) do
            model.proposed? ? "Proposed" : ""
          end
        end
        haml_tag(:div, :class => "controls") do
          haml_concat link_to("Edit", edit_project_path(model))
        end
      end
    end
  end  
  
  def chart_for_date_range(range, totals, max_size)
    # Needed to be able to use HAML helpers
    init_haml_helpers
    capture_haml do  
      range.each do |date|
        ratio = (max_size == 0) ? 1 : (100.to_f / max_size.to_f)
        css_class = ((date <= Date.today) ?  'passed' : '')
        total = totals.try(:[], date.year).try(:[], date.cweek) || 0 
        height = (total.to_f * ratio.to_f).floor 
        haml_tag(:li, {:class => css_class, :style => "height: #{height}px"}) do
          haml_tag(:span) do
            haml_concat total.to_s
          end
        end
      end
    end
  end

end
