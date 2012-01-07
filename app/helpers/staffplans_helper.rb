module StaffplansHelper
  
  def months_and_weeks_header
    cweeks_and_years = number_of_work_weeks
    current_month, current_year = nil, nil
    months_and_dates = cweeks_and_years.inject({}) do |hash, year_and_cweek|
      date = Date.commercial(year_and_cweek.keys.first, year_and_cweek.values.first)
      hash_key = Date::ABBR_MONTHNAMES[date.month]
      hash[ hash_key ] ||= []
      hash[ hash_key ] << date
      hash
    end
    
    capture_haml do
      haml_tag(:table) do
        haml_tag(:tbody) do
          # month names on top
          haml_tag(:tr) do
            haml_tag(:td, class: 'plan-actual')
            months_and_dates.each do |month_name, dates|
              haml_tag(:td) do
                haml_concat month_name
              end
              
              (dates.size - 1).times do
                haml_tag(:td)
              end
            end
          end
          
          # weeks on bottom
          haml_tag(:tr) do
            haml_tag(:td, class: 'plan-actual')
            months_and_dates.each do |month_name, dates|
              dates.each do |date|
                haml_tag(:td) do
                  haml_concat "W#{(date.mday / 7) + 1}"
                end
              end
            end
          end
        end
      end
    end
  end
end
