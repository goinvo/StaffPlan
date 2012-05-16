require 'spec_helper'

describe Project do
  describe 'validations' do
    it "should not be valid? for new instances" do
      Project.new.valid?.should be_false
    end
    
    it "should be valid? with valid attributes" do
      project = Project.new(name: Faker::Company.bs)
      project.client = FactoryGirl.create(:client)
      project.valid?.should be_true
    end
  end
  describe "after_update callback" do
    it "should update the updated_at timestamp for a user that modifies a project" do
      with_versioning do
        @source = FactoryGirl.create(:user)
        time = @source.updated_at
        @target = FactoryGirl.create(:project)
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(name: Faker::Company.name)
        @source.reload.updated_at.should > time
      end
    end
    it "should NOT update the updated_at timestamp for user A if user B modifies something about a company" do
      with_versioning do
        @source = FactoryGirl.create(:user)
        source_time = @source.updated_at
        @target = FactoryGirl.create(:project)
        @bystander = FactoryGirl.create(:user)
        bystander_time = @bystander.updated_at
        PaperTrail.whodunnit = @source.id.to_s
        @target.update_attributes(name: Faker::Company.name)
        @bystander.reload.updated_at.should == bystander_time
      end
    end
  end
end
