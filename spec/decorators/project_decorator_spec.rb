require 'spec_helper'

include Haml::Helpers

describe ProjectDecorator do
  before(:each) do
    @from = 1.week.ago(Date.today.at_beginning_of_week)
    @to = 3.months.from_now(@from)
    @date_range = []
    start = @from.clone
    while start < @to
      @date_range << start
      start = start + 7.days
    end

    # We need a project with two users

    @project = FactoryGirl.create(:project)
    @michael = FactoryGirl.create(:user)
    @john = FactoryGirl.create(:user)
    @company = Company.create(name: "Test Company")

    [@michael, @john].each do |user|
      user.assignments.create(project_id: @project.id) 
      @company.projects << @project
      @company.users << user
      user.current_company_id = @company.id
      user.save!
    end

    @john.assignments.where(project_id: @project.id).first.update_attributes(proposed: true)
  end

  describe "#chart_for_date_range" do
    it "should return a collection of HTML li elements, one per work week" do
      @decorator = ProjectDecorator.new(@project)
      snippet = Nokogiri::HTML(@decorator.chart_for_date_range(@date_range))
      snippet.css('li').count.should eq(@date_range.count)
    end

    it "should return a collection of HTML li elements with the appropriate % coloring wrt/ proposed hours" do

      [@john, @michael].each do |user|
        @date_range.each do |date|
          ww = WorkWeek.new(cweek: date.cweek, year: date.year, estimated_hours: rand(20) + 1, actual_hours: rand(20) + 1) 
          # ww.assignment.project_id = @project.id
          # ww.user_id = user.id
          ww.assignment_id = Assignment.where(user_id: user.id, project_id: @project.id).first.id
          ww.save!
        end
      end 
      @decorator = ProjectDecorator.new(@project)
      snippet = Nokogiri::HTML(@decorator.chart_for_date_range(@date_range))
      Rails.logger.debug snippet

      @date_range.each do |date|
        is_current_week = (Date.today.cweek == date.cweek && Date.today.year == date.year)
        msg = ((date.cweek < Date.today.at_beginning_of_week.cweek) && (date.year <= Date.today.at_beginning_of_week.year) or is_current_week) ? :actual_hours : :estimated_hours
        bar = snippet.css("li[data-year=\"#{date.year}\"][data-week=\"#{date.cweek}\"]").first # css method returns a NodeSet

        proposed_hours = @john.assignments.where(project_id: @project.id).first.work_weeks.where(cweek: date.cweek, year: date.year).first.send(msg)
        regular_hours = @michael.assignments.where(project_id: @project.id).first.work_weeks.where(cweek: date.cweek, year: date.year).first.send(msg)
        if msg == :actual_hours || (proposed_hours + regular_hours) == 0 
          bar.attributes["style"].value.should eq("height: #{proposed_hours + regular_hours}px")
        else
          /#7EBA8D (\d+)%/.match(bar.attributes["style"].value).captures.first.to_i.should eq((100 * proposed_hours.to_f / (proposed_hours.to_f + regular_hours.to_f)).floor)
        end
      end
    end
  end
end
