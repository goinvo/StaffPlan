require 'spec_helper'

describe WorkWeek do
  describe 'validations' do
    it "should not be valid? for new instances" do
      WorkWeek.new.valid?.should be_false
    end
    
    it "should be valid? with valid attributes" do
      ww_user = FactoryGirl.create :user
      ww_project = FactoryGirl.create :project
      ww_user.assignments.create(project_id: ww_project.id)
      a = Assignment.where(user_id: ww_user.id, project_id: ww_project.id).first
      a.work_weeks.create.should be_valid
    end
    
    it "should validate numericality of *_hours" do
      work_week = WorkWeek.new
      
      # gte
      work_week.update_attributes(
        estimated_hours: -1,
        actual_hours: -1
      ).should be_false

      work_week.errors[:estimated_hours].should_not be_empty
      work_week.errors[:actual_hours].should_not be_empty
      
      # gibberish
      work_week.update_attributes(
        estimated_hours: 'fancy',
        actual_hours: 'nancy'
      )
      
      work_week.errors[:estimated_hours].should_not be_empty
      work_week.errors[:actual_hours].should_not be_empty
    end
  end
  describe "after_update callback" do
    it "should update the updated_at timestamp for a user that modifies a work_week" do
      with_versioning do
        @source = FactoryGirl.create(:user)
        time = @source.updated_at
        @target = FactoryGirl.create(:work_week)
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(cweek: Date.today.cweek)
        @source.reload.updated_at.should > time
      end
    end
    it "should NOT update the updated_at timestamp for user A if user B modifies something about a work_week" do
      with_versioning do
        @source = FactoryGirl.create(:user)
        source_time = @source.updated_at
        @target = FactoryGirl.create(:work_week)
        @bystander = FactoryGirl.create(:user)
        bystander_time = @bystander.updated_at
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(year: Date.today.year)
        @bystander.reload.updated_at.should == bystander_time
      end
    end
  end
end
