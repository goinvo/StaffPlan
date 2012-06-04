class ProjectDecorator < Draper::Base
  
  decorates :project
  
  include Draper::LazyHelpers
  include Haml::Helpers

  def project_json
    Jbuilder.encode do |json|
      json.(self, :id, :client_id, :name, :active)

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
      haml_tag :li, {:class => project.proposed_for_user?(current_user) ? "proposed" : ""} do
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
  
  def chart_for_date_range(range, totals, max_size)
    # Needed to be able to use HAML helpers
    init_haml_helpers
    # The height of all the bar graphs need to be relative to the biggest one
    ratio = (max_size == 0) ? 1 : (100.to_f / max_size.to_f)

    capture_haml do  
      range.each do |date|
        css_class = ((date <= Date.today) ?  'passed' : '')
        # FIXME: We need to fill that hash with all the possible combinations so that we never have to .try
        totals_for_week = totals.try(:[], date.year).try(:[], date.cweek)
        if totals_for_week.present?
          total = totals_for_week.values.sum
          percentage_proposed =  100 - ((total == 0) ? 0 : (100 * totals_for_week[:proposed].to_f / total.to_f).floor)
        else
          total = 0
          percentage_proposed = 0
        end 
        height = (total.to_f * ratio.to_f).floor
        
        moz_gradient = "background-image: -moz-linear-gradient(to bottom, #5E9B69 #{percentage_proposed}%,  #7EBA8D 0%)"
        webkit_gradient = "background-image: -webkit-linear-gradient(top, #5E9B69 #{percentage_proposed}%,  #7EBA8D 0%)"
 
        gradient = (date <= Date.today) ? "" : [moz_gradient, webkit_gradient].join(";") 
        
        haml_tag(:li, {:class => css_class, :style => "height: #{height}px; #{percentage_proposed == 0 ? "" : gradient}"}) do
          haml_tag(:span) do
            haml_concat total.to_s
          end
        end
      end
    end

  end

end
