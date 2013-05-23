require 'spec_helper'

include Haml::Helpers

describe UserDecorator do
  # describe "#chart_for_date_range" do
  #   before(:each) do
  #     @from = 1.week.ago(Date.today.at_beginning_of_week)
  #     @to = 3.months.from_now(@from)
  #     @date_range = []
  #     start = @from.clone
  #     while start < @to
  #       @date_range << start
  #       start = start + 7.days
  #     end

  #     @user = user_with_clients_and_projects
  #     @company = Company.create(:name => "Test Company")
  #     @company.users << @user
  #     @company.projects << @user.assignments.all.map(&:project)
  #     @user.current_company_id = @company.id
  #     @user.save!
  #   end
    
  #   it "should return a collection of li elements, one per week" do
  #     @decorator = UserDecorator.new(@user)
  #     snippet = Nokogiri::HTML(@decorator.chart_for_date_range(@date_range))
  #     snippet.css('li').count.should eq(@date_range.count)
  #   end

  #   it "should return a collection of HTML li elements of height 0 if the user doesn't have work weeks for that date range" do
  #     @decorator = UserDecorator.new(@user)
  #     snippet = Nokogiri::HTML(@decorator.chart_for_date_range(@date_range))
  #     snippet.css('li').each do |li|
  #       /height: (\d)+px/.match(li.attributes["style"].value).captures.first.should eq("0")
  #     end 
  #   end

  #   it "should return a collection of HTML li elements whose height should be the total hours for the associated weeks" do
  #     @user.assignments.each do |ass|
  #       @date_range.each do |date|
  #         ass.work_weeks.create({
  #           :year            => date.year,
  #           :cweek           => date.cweek,
  #           :estimated_hours => rand(20) + 2,
  #           :actual_hours    => rand(20) + 2
  #         })
  #       end
  #     end

  #     @decorator = UserDecorator.new(@user)
  #     snippet = Nokogiri::HTML(@decorator.chart_for_date_range(@date_range))
  #     snippet.css('li').each do |li|
  #       week = li.attributes['data-week'].value.to_i
  #       year = li.attributes['data-year'].value.to_i
  #       height = /height: (\d)+px/.match(li.attributes["style"].value).captures.first.to_i

  #       hours = WorkWeek.where(year: year, cweek: week, user_id: @user.id)

  #       is_current_week = Date.today.cweek == week and Date.today.year == year
  #       msg = ((week < Date.today.at_beginning_of_week.cweek and year <= Date.today.at_beginning_of_week.year) or is_current_week) ? :actual_hours : :estimated_hours

  #       hours.all.inject(0) {|memo, element| memo += element.send(msg) || 0}.should eq(height) 
  #     end 
  #   end
  # end

  describe "#staff_plan_json" do

  end

  describe "#project_json" do

  end
end
