module ProjectHelper
  def chart_for_project(project, date_range, totals_per_week, max_size)
    capture_haml do 
      date_range.each do |date|
        ratio = max_size == 0 ? 1 : (100.to_f / max_size.to_f)
        css_class = ((date <= Date.today) ?  'passed' : '')
        actual_or_estimated_hours = date.past? ? :actual_hours : :estimated_hours
        total = totals_per_week.try(:[], date.year).try(:[], date.cweek) || 0 
        height = (total.to_f * ratio).floor 
        haml_tag :li, {:class => css_class, :style => "height: #{height}px"} do
          haml_tag :span do 
            haml_concat total.to_s
          end
        end
      end
    end
  end
end
