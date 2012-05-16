require 'spec_helper'

describe Company do
  describe "after_update callback" do
    it "should update the updated_at timestamp for a user that modifies a company" do
      with_versioning do
        @source = FactoryGirl.create(:user)
        time = @source.updated_at
        @target = FactoryGirl.create(:company)
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(name: Faker::Company.name)
        @source.reload.updated_at.should > time
      end
    end
    it "should NOT update the updated_at timestamp for user A if user B modifies something about a company" do
      with_versioning do
        @source = FactoryGirl.create(:user)
        source_time = @source.updated_at
        @target = FactoryGirl.create(:company)
        @bystander = FactoryGirl.create(:user)
        bystander_time = @bystander.updated_at
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(name: Faker::Company.name)
        @bystander.reload.updated_at.should == bystander_time
      end
    end
  end

  describe "total_recap_for_date_range" do
    it "should be all nice and dandy" do
      %w(work_week project user client company).each do |model|
        model.classify.constantize.destroy_all
      end

      @users = [].tap do |users|
        4.times do
          users << FactoryGirl.create(:user)
        end
      end

      @allocations = [].tap do |values|
        Range.new(50, 53).each do |i|
          values << {cweek: i, year: 2012, estimated: rand(30), actual: rand(30)}
        end
        Range.new(1, 10).each do |i|
          values << {cweek: i, year: 2013, estimated: rand(30), actual: rand(30)}
        end
      end

      @company = FactoryGirl.create(:company).tap do |company|
        2.times do
          company.projects << FactoryGirl.create(:project).tap do |project|
            @users.each do |user|
              @allocations.each do |week|
                WorkWeek.create(
                  :cweek           => week[:cweek],
                  :year            => week[:year],
                  :estimated_hours => week[:estimated],
                  :actual_hours    => week[:actual]
                ).tap do |ww|
                  ww.user_id = user.id
                  ww.project_id = project.id
                  ww.save!
                end
              end
            end
          end
        end
      end
      lower = Date.new(2012, 12, 20).at_beginning_of_week
      upper = 3.months.from_now(lower)
      result = @company.total_recap_for_date_range(lower, upper)
      
      # Structural check 
      result.keys.sort.should eq(@company.projects.map(&:id).sort)
      result.all? do |k,v|
        ([[], [2012], [2013], [2012, 2013]].should include(v.keys.sort)) and v.values.all? do |totals_per_week|
          totals_per_week.should be_a(Hash)
          totals_per_week.all? do |iso_week, total|
            (1..10).to_a.concat((50..53).to_a).should include(iso_week)
            total.should <= 120
          end
        end 
      end

    end
  end
end
